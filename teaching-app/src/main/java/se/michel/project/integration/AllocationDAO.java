package se.michel.project.integration;

import se.michel.project.model.ExerciseAllocationInfo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AllocationDAO {

    public void createAAllocation(Connection connection, int employeeId, int courseInstanceId, int teachingActivityId, double allocatedHours) throws SQLException 
    {

        String sql = """
            INSERT INTO allocation (employee_id, course_instance_id, teaching_activity_id, allocated_hours)
            VALUES (?, ?, ?, ?)
            """;

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, employeeId);
            stmt.setInt(2, courseInstanceId);
            stmt.setInt(3, teachingActivityId);
            stmt.setDouble(4, allocatedHours);
            stmt.executeUpdate();
        }
    }

    public void deleteAAllocation(Connection connection, int employeeId, int courseInstanceId, int teachingActivityId) throws SQLException 
    {
        String sql = """
            DELETE FROM allocation
            WHERE employee_id = ?
              AND course_instance_id = ?
              AND teaching_activity_id = ?
            """;

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, employeeId);
            stmt.setInt(2, courseInstanceId);
            stmt.setInt(3, teachingActivityId);
            stmt.executeUpdate();
        }
    }

    public int countCourseInstancesForATeacherInAPeriod(Connection connection, int employeeId, String studyPeriod, int studyYear) throws SQLException 
    {

        String sql = """

    SELECT COUNT(DISTINCT course_instance.course_instance_id) AS countId
    FROM allocation
    JOIN course_instance ON allocation.course_instance_id = course_instance.course_instance_id
    WHERE allocation.employee_id = ?
    AND course_instance.study_period = ?
    AND course_instance.study_year = ?
            """;

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, employeeId);
            stmt.setString(2, studyPeriod);
            stmt.setInt(3, studyYear);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("countId");
                }
                return 0;
            }
        }
    }

    public List<ExerciseAllocationInfo> findExerciseAllocationsForATeacher(Connection connection, int employeeId) throws SQLException 
    {
        String sql = """
            SELECT 
    course.course_code,
    course_instance.course_instance_id,
    course_instance.study_period,
    course_instance.study_year,
    teaching_activity.teaching_activity_name,
    allocation.employee_id,
    allocation.allocated_hours
    
    FROM allocation
    JOIN teaching_activity ON teaching_activity.teaching_activity_id = allocation.teaching_activity_id
    JOIN course_instance ON course_instance.course_instance_id = allocation.course_instance_id
    JOIN course_layout ON course_layout.course_layout_id = course_instance.course_layout_id
    JOIN course ON course.course_id = course_layout.course_id
    WHERE teaching_activity.teaching_activity_name = 'Exercise'
    AND allocation.employee_id = ?
            """;

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, employeeId);

            try (ResultSet rs = stmt.executeQuery()) {
                List<ExerciseAllocationInfo> result = new ArrayList<>();
                while (rs.next()) {
                    result.add(new ExerciseAllocationInfo(
                            rs.getString("course_code"),
                            rs.getInt("course_instance_id"),
                            rs.getString("study_period"),
                            rs.getInt("study_year"),
                            rs.getString("teaching_activity_name"),
                            rs.getInt("employee_id"),
                            rs.getDouble("allocated_hours")
                    ));
                }
                return result;
            }
        }
    }
}
