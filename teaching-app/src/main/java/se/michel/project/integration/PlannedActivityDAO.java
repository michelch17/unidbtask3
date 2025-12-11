package se.michel.project.integration;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class PlannedActivityDAO {

    public void createAPlannedActivity(Connection connection, int courseInstanceId, int teachingActivityId, double plannedHours) throws SQLException 
    {
        String sql = """
            INSERT INTO planned_activity (course_instance_id, teaching_activity_id, planned_hours)
            VALUES (?, ?, ?)
            """;
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, courseInstanceId);
            stmt.setInt(2, teachingActivityId);
            stmt.setDouble(3, plannedHours);
            stmt.executeUpdate();
        }
    }
}
