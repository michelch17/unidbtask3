package se.michel.project.integration;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import se.michel.project.model.StudyPeriodYear;

public class CourseInstanceDAO {

    public int findNumStudentsUpdate(Connection connection, int courseInstanceId) throws SQLException {
        String sql = """
            SELECT num_students
            FROM course_instance
            WHERE course_instance_id = ?
            FOR UPDATE
            """;

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, courseInstanceId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLException("Theree is no course_instance with id " + courseInstanceId);
                }
                return rs.getInt("num_students");
            }
        }
    }

    public void updateNumStudents(Connection connection, int courseInstanceId, int newNumStudents) throws SQLException {
        String sql = """
            UPDATE course_instance
            SET num_students = ?
            WHERE course_instance_id = ?
            """;

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, newNumStudents);
            stmt.setInt(2, courseInstanceId);
            int updated = stmt.executeUpdate();
            if (updated != 1) {
                throw new SQLException("The update on num_students affected " + updated + " rows for id " + courseInstanceId);
            }
        }
    }

    public StudyPeriodYear findStudyPeriodYear(Connection connection, int courseInstanceId) throws SQLException {
        String sql = """
            SELECT study_period, study_year
            FROM course_instance
            WHERE course_instance_id = ?
            """;

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, courseInstanceId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLException("There is no no course_instance with id " + courseInstanceId);
                }
                String period = rs.getString("study_period");
                int year = rs.getInt("study_year");
                return new StudyPeriodYear(period, year);
            }
        }
    }
}
