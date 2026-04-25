package dao;

import model.Reservation;
import util.DatabaseConnection;
import java.sql.*;
import java.sql.Date;
import java.util.*;

public class ReservationDAO {

    private final String SELECT_BASE = "SELECT r.*, v.frais, c.nom, c.numtel FROM reserver r " +
            "JOIN voiture v ON r.idvoit = v.idvoit " +
            "JOIN client c ON r.idcli = c.idcli ";

    /**
     * 
     * @param idvoit  Identifiant de la voiture
     * @param payment Type de paiement (sans avance, avec avance, tout payé)
     */
    public List<Reservation> getVoyageursParStatut(String idvoit, String payment) {
        List<Reservation> list = new ArrayList<>();
        String sql = SELECT_BASE + " WHERE r.idvoit = ? AND r.payment = ? ORDER BY c.nom ASC";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, idvoit);
            pstmt.setString(2, payment);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToReservation(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Ajout de reservation
    public boolean ajouter(Reservation r) {
        String sqlRes = "INSERT INTO reserver (idreserv, idvoit, idcli, place, date_voyage, payment, montant_avance) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement pstmtRes = conn.prepareStatement(sqlRes)) {

                pstmtRes.setString(1, r.getIdreserv());
                pstmtRes.setString(2, r.getIdvoit());
                pstmtRes.setInt(3, r.getIdcli());
                pstmtRes.setInt(4, r.getPlace());
                pstmtRes.setDate(5, r.getDateVoyage());
                pstmtRes.setString(6, r.getPayment());
                pstmtRes.setInt(7, r.getMontantAvance());

                pstmtRes.executeUpdate();

                occuperPlaceTransactionnel(conn, r.getIdvoit(), r.getPlace());

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean ajouterPlusieursPlaces(Reservation r, String[] places) {
        String sqlRes = "INSERT INTO reserver (idreserv, idvoit, idcli, place, date_voyage, payment, montant_avance) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement pstmtRes = conn.prepareStatement(sqlRes)) {

                int montantParPlace = r.getMontantAvance() / (places.length > 0 ? places.length : 1);

                for (String p : places) {
                    int numPlace = Integer.parseInt(p.trim());
                    pstmtRes.setString(1, r.getIdreserv());
                    pstmtRes.setString(2, r.getIdvoit());
                    pstmtRes.setInt(3, r.getIdcli());
                    pstmtRes.setInt(4, numPlace);
                    pstmtRes.setDate(5, r.getDateVoyage());
                    pstmtRes.setString(6, r.getPayment());
                    pstmtRes.setInt(7, montantParPlace);
                    pstmtRes.executeUpdate();

                    occuperPlaceTransactionnel(conn, r.getIdvoit(), numPlace);
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // read by jessiiiiiiiiiiiiiii
    public List<Reservation> getAll() {
        List<Reservation> reservations = new ArrayList<>();
        String sql = SELECT_BASE + " ORDER BY r.date_reserv DESC";
        try (Connection conn = DatabaseConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                reservations.add(mapResultSetToReservation(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }

    public List<Reservation> getAllByCodeReserv(String idreserv) {
        List<Reservation> list = new ArrayList<>();
        String sql = SELECT_BASE + " WHERE r.idreserv = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, idreserv);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToReservation(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Updateeeeeeeeeeee
    public boolean modifier(Reservation r, String[] nouvellesPlaces) {
        String sqlDeleteOld = "DELETE FROM reserver WHERE idreserv = ?";
        String sqlInsertNew = "INSERT INTO reserver (idreserv, idvoit, idcli, place, date_voyage, payment, montant_avance) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                List<Reservation> anciennes = getAllByCodeReserv(r.getIdreserv());
                for (Reservation anc : anciennes) {
                    libererPlaceTransactionnel(conn, anc.getIdvoit(), anc.getPlace());
                }

                try (PreparedStatement psDel = conn.prepareStatement(sqlDeleteOld)) {
                    psDel.setString(1, r.getIdreserv());
                    psDel.executeUpdate();
                }

                int montantParPlace = r.getMontantAvance() / (nouvellesPlaces.length > 0 ? nouvellesPlaces.length : 1);
                try (PreparedStatement psIns = conn.prepareStatement(sqlInsertNew)) {
                    for (String p : nouvellesPlaces) {
                        int numPlace = Integer.parseInt(p.trim());

                        psIns.setString(1, r.getIdreserv());
                        psIns.setString(2, r.getIdvoit());
                        psIns.setInt(3, r.getIdcli());
                        psIns.setInt(4, numPlace);
                        psIns.setDate(5, r.getDateVoyage());
                        psIns.setString(6, r.getPayment());
                        psIns.setInt(7, montantParPlace);
                        psIns.executeUpdate();

                        occuperPlaceTransactionnel(conn, r.getIdvoit(), numPlace);
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Deletetteeeeeee

    public boolean supprimerToutesPlaces(String idreserv) {
        List<Reservation> places = getAllByCodeReserv(idreserv);
        String sqlDelete = "DELETE FROM reserver WHERE idreserv = ?";

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                for (Reservation r : places) {
                    libererPlaceTransactionnel(conn, r.getIdvoit(), r.getPlace());
                }

                try (PreparedStatement pstmt = conn.prepareStatement(sqlDelete)) {
                    pstmt.setString(1, idreserv);
                    pstmt.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean supprimerParId(int idTechnique) {
        String sqlDelete = "DELETE FROM reserver WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sqlDelete)) {
            pstmt.setInt(1, idTechnique);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // autres focn

    public List<Reservation> getVoyageursParVoiture(String idvoit) {
        List<Reservation> list = new ArrayList<>();
        String sql = SELECT_BASE + " WHERE r.idvoit = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, idvoit);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToReservation(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getRecetteTotale() {
        String sql = "SELECT SUM(montant_avance) FROM reserver";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery()) {
            if (rs.next())
                return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // on gère les places our chaque voiture
    private void occuperPlaceTransactionnel(Connection conn, String idvoit, int place) throws SQLException {
        updateStatus(conn, idvoit, place, "oui");
    }

    private void libererPlaceTransactionnel(Connection conn, String idvoit, int place) throws SQLException {
        updateStatus(conn, idvoit, place, "non");
    }

    private void updateStatus(Connection conn, String idvoit, int place, String etat) throws SQLException {
        String sql = "UPDATE place SET occupation = ? WHERE idvoit = ? AND place = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, etat);
            pstmt.setString(2, idvoit);
            pstmt.setInt(3, place);
            pstmt.executeUpdate();
        }
    }

    // utilitaires

    public String genererProchainCodeReserv() {
        String sql = "SELECT idreserv FROM reserver ORDER BY id DESC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                String lastId = rs.getString("idreserv");
                int num = Integer.parseInt(lastId.substring(3)) + 1;
                return String.format("RES%03d", num);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "RES001";
    }

    private Reservation mapResultSetToReservation(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setId(rs.getInt("id"));
        r.setIdreserv(rs.getString("idreserv"));
        r.setIdvoit(rs.getString("idvoit"));
        r.setIdcli(rs.getInt("idcli"));
        r.setPlace(rs.getInt("place"));
        r.setDateReserv(rs.getTimestamp("date_reserv"));
        r.setDateVoyage(rs.getDate("date_voyage"));
        r.setPayment(rs.getString("payment"));
        r.setMontantAvance(rs.getInt("montant_avance"));

        r.setFraisFixe(rs.getInt("frais"));
        r.setNomClient(rs.getString("nom"));
        r.setNumTelClient(rs.getString("numtel"));
        return r;
    }

    public List<Integer> getPlacesOccupeesParDate(String idvoit, String dateVoyage) {
        List<Integer> places = new ArrayList<>();
        String sql = "SELECT place FROM reserver WHERE idvoit = ? AND date_voyage = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, idvoit);
            pstmt.setString(2, dateVoyage);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    places.add(rs.getInt("place"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return places;
    }

    public Reservation getById(String idreserv) {
        String sql = SELECT_BASE + " WHERE r.idreserv = ? LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, idreserv);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToReservation(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Reservation> getPlacesByClientAndVoitureAndDate(int idcli, String idvoit, Date dateVoyage) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = SELECT_BASE + " WHERE r.idcli = ? AND r.idvoit = ? AND r.date_voyage = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idcli);
            pstmt.setString(2, idvoit);
            pstmt.setDate(3, new java.sql.Date(dateVoyage.getTime()));
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }

    public List<Reservation> getPlacesByClientAndVoitureAndDate(int idcli, String idvoit, String dateVoyage) {
        List<Reservation> reservations = new ArrayList<>();
        String sql = SELECT_BASE + " WHERE r.idcli = ? AND r.idvoit = ? AND r.date_voyage = ?";
        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idcli);
            pstmt.setString(2, idvoit);
            pstmt.setString(3, dateVoyage);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reservations.add(mapResultSetToReservation(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reservations;
    }
}