package dao;

import model.Voiture;
import util.DatabaseConnection;
import java.sql.*;
import java.util.*;

public class VoitureDAO {

    public List<Voiture> getAll() {
        List<Voiture> voitures = new ArrayList<>();
        String sql = "SELECT * FROM voiture ORDER BY idvoit";
        try (Connection conn = DatabaseConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                voitures.add(mapResultSetToVoiture(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return voitures;
    }

    public boolean ajouter(Voiture v) {
        String sql = "INSERT INTO voiture (idvoit, Design, type, nbrplace, frais) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, v.getIdvoit());
            pstmt.setString(2, v.getDesign());
            pstmt.setString(3, v.getType());
            pstmt.setInt(4, v.getNbrplace());
            pstmt.setInt(5, v.getFrais());

            int result = pstmt.executeUpdate();
            if (result > 0) {
                // On passe aussi le TYPE pour le nommage des places
                genererPlaces(v.getIdvoit(), v.getNbrplace(), v.getType());
            }
            return result > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void genererPlaces(String idvoit, int nbrplace, String type) {
        String sql = "INSERT INTO place (idvoit, place, occupation, nom_place) VALUES (?, ?, 'non', ?)";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            for (int i = 1; i <= nbrplace; i++) {
                String nomGenere = "";

                // Logique de nommage selon la position
                if (i == 1) {
                    nomGenere = "Chauffeur";
                } else if (i <= 3) {
                    nomGenere = "Cabine Avant";
                } else {
                    // Calcul du rang/banc
                    if ("VIP".equalsIgnoreCase(type)) {
                        int rang = ((i - 4) / 2) + 1;
                        nomGenere = "VIP - Rang " + rang;
                    } else {
                        int banc = ((i - 4) / 3) + 1;
                        nomGenere = "Banc " + banc;
                    }
                }

                pstmt.setString(1, idvoit);
                pstmt.setInt(2, i);
                pstmt.setString(3, nomGenere); // On insère le nom calculé
                pstmt.addBatch();
            }
            pstmt.executeBatch();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Utilitaire de nommage pour la précision du projet
    private String determinerNomPlace(int i, String type) {
        if (i == 1)
            return "Chauffeur";
        if (i <= 3)
            return "Cabine Avant";

        // Calcul du rang après la cabine
        int rang = ((i - 4) / 3) + 1;

        if ("VIP".equalsIgnoreCase(type))
            return "VIP - Rang " + rang;
        if ("premium".equalsIgnoreCase(type))
            return "Premium - Banc " + rang;
        return "Banc " + rang;
    }

    // --- LE RESTE RESTE IDENTIQUE MAIS OPTIMISÉ ---

    public boolean modifier(Voiture v) {
        String sql = "UPDATE voiture SET Design=?, type=?, nbrplace=?, frais=? WHERE idvoit=?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, v.getDesign());
            pstmt.setString(2, v.getType());
            pstmt.setInt(3, v.getNbrplace());
            pstmt.setInt(4, v.getFrais());
            pstmt.setString(5, v.getIdvoit());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean supprimer(String idvoit) {
        String sqlPlaces = "DELETE FROM place WHERE idvoit=?";
        String sqlVoiture = "DELETE FROM voiture WHERE idvoit=?";
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement pst1 = conn.prepareStatement(sqlPlaces);
                    PreparedStatement pst2 = conn.prepareStatement(sqlVoiture)) {

                pst1.setString(1, idvoit);
                pst1.executeUpdate();

                pst2.setString(1, idvoit);
                int res = pst2.executeUpdate();

                conn.commit();
                return res > 0;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Voiture getById(String idvoit) {
        String sql = "SELECT * FROM voiture WHERE idvoit=?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, idvoit);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next())
                    return mapResultSetToVoiture(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Voiture> rechercher(String motCle) {
        List<Voiture> voitures = new ArrayList<>();
        String sql = "SELECT * FROM voiture WHERE Design LIKE ? OR type LIKE ? OR idvoit LIKE ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String query = "%" + motCle + "%";
            pstmt.setString(1, query);
            pstmt.setString(2, query);
            pstmt.setString(3, query);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    voitures.add(mapResultSetToVoiture(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return voitures;
    }

    private Voiture mapResultSetToVoiture(ResultSet rs) throws SQLException {
        Voiture v = new Voiture();
        v.setIdvoit(rs.getString("idvoit"));
        v.setDesign(rs.getString("Design"));
        v.setType(rs.getString("type"));
        v.setNbrplace(rs.getInt("nbrplace"));
        v.setFrais(rs.getInt("frais"));
        return v;
    }
}