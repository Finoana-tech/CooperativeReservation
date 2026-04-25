package model;

import java.sql.Date;
import java.sql.Timestamp;

public class Reservation {
    // 1. Identifiants
    private int id; // Clé primaire technique (auto-increment)
    private String idreserv; // Code de réservation (ex: RS001) - Identifiant métier

    // 2. Relations
    private String idvoit;
    private int idcli;

    // 3. Détails du voyage
    private int place;
    private Timestamp dateReserv;
    private Date dateVoyage;

    // 4. Paiement
    private String payment;
    private int montantAvance;

    // 5. Attributs calculés (Pour les exigences du PDF : Reste à payer, Recette)
    private int fraisFixe; // Frais par place (vient de la table voiture)
    private String nomClient; // Pour faciliter l'affichage dans la liste et le reçu
    private String numTelClient;

    public Reservation() {
    }

    // --- GETTERS ET SETTERS ---

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getIdreserv() {
        return idreserv;
    }

    public void setIdreserv(String idreserv) {
        this.idreserv = idreserv;
    }

    public String getIdvoit() {
        return idvoit;
    }

    public void setIdvoit(String idvoit) {
        this.idvoit = idvoit;
    }

    public int getIdcli() {
        return idcli;
    }

    public void setIdcli(int idcli) {
        this.idcli = idcli;
    }

    public int getPlace() {
        return place;
    }

    public void setPlace(int place) {
        this.place = place;
    }

    public Timestamp getDateReserv() {
        return dateReserv;
    }

    public void setDateReserv(Timestamp dateReserv) {
        this.dateReserv = dateReserv;
    }

    public Date getDateVoyage() {
        return dateVoyage;
    }

    public void setDateVoyage(Date dateVoyage) {
        this.dateVoyage = dateVoyage;
    }

    public String getPayment() {
        return payment;
    }

    public void setPayment(String payment) {
        this.payment = payment;
    }

    public int getMontantAvance() {
        return montantAvance;
    }

    public void setMontantAvance(int montantAvance) {
        this.montantAvance = montantAvance;
    }

    // --- LOGIQUE METIER (Exigences du PDF) ---

    public void setFraisFixe(int frais) {
        this.fraisFixe = frais;
    }

    public int getFraisFixe() {
        return fraisFixe;
    }

    /**
     * Calcule le reste à payer pour CETTE place.
     * Le PDF demande de gérer le reste pas encore payé.
     */
    public int getReste() {
        if ("tout payé".equalsIgnoreCase(this.payment)) {
            return 0;
        }
        return this.fraisFixe - this.montantAvance;
    }

    // Getters/Setters pour les infos clients (utile pour le PDF du reçu)
    public String getNomClient() {
        return nomClient;
    }

    public void setNomClient(String nomClient) {
        this.nomClient = nomClient;
    }

    public String getNumTelClient() {
        return numTelClient;
    }

    public void setNumTelClient(String numTelClient) {
        this.numTelClient = numTelClient;
    }
}