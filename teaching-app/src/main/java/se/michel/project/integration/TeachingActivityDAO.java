package se.michel.project.integration;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class TeachingActivityDAO {

    public Integer findActivityIdName(Connection connection, String name) throws SQLException {
        String sql = "SELECT teaching_activity_id FROM teaching_activity WHERE teaching_activity_name = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, name);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("teaching_activity_id");
                }
                return null;
            }
        }
    }

    public int createTeachingActivity(Connection connection, String name, double factor) throws SQLException {
        String sql = """
            INSERT INTO teaching_activity (teaching_activity_name, factor)
            VALUES (?, ?)
            RETURNING teaching_activity_id
            """;
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, name);
            stmt.setDouble(2, factor);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("teaching_activity_id");
                }
                throw new SQLException("Creating teaching activity failed, no ID has been returned.");
            }
        }
    }
}
