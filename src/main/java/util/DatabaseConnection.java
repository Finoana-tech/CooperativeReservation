package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/cooperative?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER = "jessica";
    private static final String PASSWORD = "elodie23";

    private static Connection connection = null;

    public static Connection getConnection() {
        try {
            // On vérifie si la connexion est nulle OU si elle a été fermée/perdue
            if (connection == null || connection.isClosed()) {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(URL, USER, PASSWORD);
                System.out.println("Connexion à la base 'cooperative' réussie !");
            }
        } catch (ClassNotFoundException e) {
            System.err.println("Erreur de Driver : " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("Erreur SQL : " + e.getMessage());
        }
        return connection;
    }

    public static void closeConnection() {
        if (connection != null) {
            try {
                if (!connection.isClosed()) {
                    connection.close();
                    connection = null; // Important : remettre à null après fermeture
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}