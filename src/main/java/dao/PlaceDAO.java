package dao;

import model.Place;
import model.Voiture;
import util.DatabaseConnection;
import java.sql.*;
import java.util.*;

public class PlaceDAO {

    // --- GÉNÉRATION AUTOMATIQUE (Appelé lors de la création d'une voiture)
    public boolean genererPlaces(Voiture voiture) {
        String sql = "INSERT INTO place (idvoit, place, occupation, nom_place) VALUES (?, ?, 'non', ?)";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            for (int i = 1; i <= voiture.getNbrplace(); i++) {
                pstmt.setString(1, voiture.getIdvoit());
                pstmt.setInt(2, i);
                pstmt.setString(3, genererNomPlace(i, voiture.getType()));
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private String genererNomPlace(int n, String type) {
        if (n == 1)
            return "Chauffeur";
        if (n <= 3)
            return "Cabine Avant";
        int numBanc = ((n - 4) / 3) + 1;
        if ("VIP".equalsIgnoreCase(type))
            return "VIP - Banc " + numBanc;
        if ("premium".equalsIgnoreCase(type))
            return "Premium - Banc " + numBanc;
        return "Banc " + numBanc;
    }

    // --- AJOUT : Méthode nécessaire pour CheckPlacesServlet ---
    public String getNomPlaceSpecifique(String idvoit, int numPlace) {
        String nomPlace = "Place " + numPlace; // Valeur par défaut
        String sql = "SELECT nom_place FROM place WHERE idvoit = ? AND place = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, idvoit);
            pstmt.setInt(2, numPlace);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String val = rs.getString("nom_place");
                    if (val != null && !val.isEmpty()) {
                        nomPlace = val;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return nomPlace;
    }

    // --- EXIGENCE PDF : Afficher les places libres d'une voiture par DATE ---
    public List<Place> getPlacesLibresParDate(String idvoit, String dateVoyage) {
        List<Place> libres = new ArrayList<>();
        String sql = "SELECT * FROM place WHERE idvoit = ? AND place NOT IN (" +
                "SELECT place FROM reserver WHERE idvoit = ? AND date_voyage = ?)";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, idvoit);
            pstmt.setString(2, idvoit);
            pstmt.setString(3, dateVoyage);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Place p = new Place();
                    p.setIdvoit(rs.getString("idvoit"));
                    p.setPlace(rs.getInt("place"));
                    p.setNomPlace(rs.getString("nom_place"));
                    libres.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return libres;
    }

    // --- SYNCHRONISATION ---
    public boolean updateOccupation(String idvoit, int place, String etat) {
        String sql = "UPDATE place SET occupation = ? WHERE idvoit = ? AND place = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, etat);
            pstmt.setString(2, idvoit);
            pstmt.setInt(3, place);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public void supprimerPlacesParVoiture(String idvoit) {
        String sql = "DELETE FROM place WHERE idvoit = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, idvoit);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}