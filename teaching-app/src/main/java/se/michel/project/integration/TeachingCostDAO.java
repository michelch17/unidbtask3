package se.michel.project.integration;

import se.michel.project.model.TeachingCost;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class TeachingCostDAO {

    public TeachingCost findTeachingCostCourseInstance(Connection connection, int courseInstanceId)
            throws SQLException {

        String sql = """
        
        WITH avg_salary AS (
        SELECT AVG(salary_amount) AS avg_sal
        FROM salary_history
        WHERE valid_to IS NULL
    ),
    planned AS (
        SELECT 
            course_instance.course_instance_id,
            course.course_code,
            course_instance.study_period,
            course_instance.study_year,
            SUM(planned_activity.planned_hours * teaching_activity.factor * avg_salary.avg_sal) / 1000 AS planned_cost
        FROM course_instance
        JOIN course_layout ON course_instance.course_layout_id = course_layout.course_layout_id
        JOIN course ON course_layout.course_id = course.course_id
        JOIN planned_activity ON planned_activity.course_instance_id = course_instance.course_instance_id
        JOIN teaching_activity ON planned_activity.teaching_activity_id = teaching_activity.teaching_activity_id
        CROSS JOIN avg_salary
        WHERE course_instance.course_instance_id = ?
        GROUP BY course_instance.course_instance_id, course.course_code, course_instance.study_period, course_instance.study_year
    ),
    actual AS (
        SELECT 
            course_instance.course_instance_id,
            SUM(allocation.allocated_hours * teaching_activity.factor * salary_history.salary_amount) / 1000 AS actual_cost
        FROM course_instance
        JOIN allocation ON allocation.course_instance_id = course_instance.course_instance_id
        JOIN teaching_activity ON allocation.teaching_activity_id = teaching_activity.teaching_activity_id
        JOIN salary_history ON salary_history.employee_id = allocation.employee_id
        WHERE salary_history.valid_to IS NULL
        AND course_instance.course_instance_id = ?
        GROUP BY course_instance.course_instance_id
    )
    SELECT 
        planned.course_code,
        planned.course_instance_id,
        planned.study_period,
        planned.study_year,
        planned.planned_cost,
        COALESCE(actual.actual_cost, 0) AS actual_cost
    FROM planned
    LEFT JOIN actual ON actual.course_instance_id = planned.course_instance_id;
            """;

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, courseInstanceId);
            stmt.setInt(2, courseInstanceId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int currentYear = java.time.LocalDate.now().getYear();
                    int studyYear = rs.getInt("study_year");
                    if (studyYear != currentYear) {
                        return null;
                    }

                    return new TeachingCost(
                        rs.getString("course_code"),
                        rs.getInt("course_instance_id"),
                        rs.getString("study_period"),
                        rs.getDouble("planned_cost"),
                        rs.getDouble("actual_cost")
                    );
                }
            }
        }
        return null;
    }
}


