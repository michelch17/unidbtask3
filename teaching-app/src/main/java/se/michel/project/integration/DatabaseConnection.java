package se.michel.project.integration;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    private static final String URL = "jdbc:postgresql://localhost:5432/NAMEOFDB"; // Adjust name for your database
    private static final String USERNAME = "USERNAME";  //  Adjust to your username
    private static final String PASSWORD = "PASSWORD"; // Adust to your password

    public static Connection getConnection() throws SQLException {
        Connection connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        connection.setAutoCommit(false);
        return connection;
    }
}
