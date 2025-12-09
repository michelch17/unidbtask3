package se.michel.project.controller;

import se.michel.project.integration.AllocationDAO;
import se.michel.project.integration.CourseInstanceDAO;
import se.michel.project.integration.DatabaseConnection;
import se.michel.project.integration.TeachingCostDAO;
import se.michel.project.model.StudyPeriodYear;
import se.michel.project.model.TeachingCost;
import se.michel.project.integration.TeachingActivityDAO;
import se.michel.project.integration.PlannedActivityDAO;
import se.michel.project.model.ExerciseAllocationInfo;
import java.util.List;

import java.sql.Connection;
import java.sql.SQLException;

public class CostController {

    private final TeachingCostDAO teachingCostDAO = new TeachingCostDAO();
    private final CourseInstanceDAO courseInstanceDAO = new CourseInstanceDAO();
    private final AllocationDAO allocationDAO = new AllocationDAO();
    private final TeachingActivityDAO teachingActivityDAO = new TeachingActivityDAO();
    private final PlannedActivityDAO plannedActivityDAO = new PlannedActivityDAO();

    public TeachingCost computeTeachingCostCourseInstance(int courseInstanceId) throws SQLException {
        try (Connection connection = DatabaseConnection.getConnection()) {
            TeachingCost cost = teachingCostDAO.findTeachingCostCourseInstance(connection, courseInstanceId);
            connection.commit(); 
            return cost;
        }
    }

    public TeachingCost increaseStudentsComputeCost(int courseInstanceId, int changeNum) throws SQLException {
        Connection connection = DatabaseConnection.getConnection();
        try {
            int current = courseInstanceDAO.findNumStudentsUpdate(connection, courseInstanceId);

            int updated = current + changeNum;

            courseInstanceDAO.updateNumStudents(connection, courseInstanceId, updated);

            TeachingCost newCost = teachingCostDAO.findTeachingCostCourseInstance(connection, courseInstanceId);

            connection.commit();
            return newCost;
        } catch (SQLException sqlexception) {
            try {
                connection.rollback();
            } catch (SQLException ignore) {}
            throw sqlexception;
        } finally {
            try {
                connection.close();
            } catch (SQLException ignore) {
            }
        }
    }

    public void allocateTeachingActivity(int employeeId, int courseInstanceId, int teachingActivityId, double allocatedHours) throws SQLException 
    {
        Connection connection = DatabaseConnection.getConnection();
        try {
            StudyPeriodYear sp = courseInstanceDAO.findStudyPeriodYear(connection, courseInstanceId);

            int currentCount = allocationDAO.countCourseInstancesForATeacherInAPeriod(
                    connection, employeeId, sp.getPeriod(), sp.getYear());

            if (currentCount >= 4) {
                connection.rollback();
                throw new IllegalStateException(
                        "Teacher " + employeeId + " already has " + currentCount +
                        " course instances in period " + sp.getPeriod() + " " + sp.getYear() +
                        ". The max allowed is 4.");
            }

            allocationDAO.createAAllocation(connection, employeeId, courseInstanceId, teachingActivityId, allocatedHours);

            connection.commit();
        } catch (SQLException | IllegalStateException exceptions) {
            try {
                connection.rollback();
            } catch (SQLException ignore) {
            }
            throw exceptions;
        } finally {
            try {
                connection.close();
            } catch (SQLException ignore) {}
        }
    }

    public void deallocateTeachingActivity(int employeeId, int courseInstanceId, int teachingActivityId) throws SQLException 
    {
        Connection connection = DatabaseConnection.getConnection();
        try {
            allocationDAO.deleteAAllocation(connection, employeeId, courseInstanceId, teachingActivityId);
            connection.commit();
        } catch (SQLException sqlexception) {
            try {
                connection.rollback();
            } catch (SQLException ignore) {}
            throw sqlexception;
        } finally {
            try {
                connection.close();
            } catch (SQLException ignore) {}
        }
    }

        public List<ExerciseAllocationInfo> addExerciseActivityAndAllocate(
            int employeeId,
            int courseInstanceId,
            double plannedHours,
            double allocatedHours,
            double factorExercise) throws SQLException {

        int exerciseActivityId = 8;

        try (Connection connection = DatabaseConnection.getConnection()) {
            Integer excId = teachingActivityDAO.findActivityIdName(connection, "Exercise");
            if (excId == null) {
                exerciseActivityId = teachingActivityDAO.createTeachingActivity(connection, "Exercise", factorExercise);
            }

            plannedActivityDAO.createAPlannedActivity(connection, courseInstanceId, exerciseActivityId, plannedHours);

            connection.commit();
        }

        allocateTeachingActivity(employeeId, courseInstanceId, exerciseActivityId, allocatedHours);

        try (Connection connection = DatabaseConnection.getConnection()) {
            List<ExerciseAllocationInfo> ExcersisceInfo =
                    allocationDAO.findExerciseAllocationsForATeacher(connection, employeeId);
            connection.commit();
            return ExcersisceInfo;
        }
    }
}
