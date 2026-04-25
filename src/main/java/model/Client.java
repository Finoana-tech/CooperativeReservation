package model;

public class Client {
    private int idcli;
    private String nom;
    private String numtel;

    public Client() {
    }

    // Utile pour la récupération depuis la base (avec ID)
    public Client(int idcli, String nom, String numtel) {
        this.idcli = idcli;
        this.nom = nom;
        this.numtel = numtel;
    }

    // Utile pour l'ajout d'un nouveau client (sans ID car auto_increment)
    public Client(String nom, String numtel) {
        this.nom = nom;
        this.numtel = numtel;
    }

    public int getIdcli() {
        return idcli;
    }

    public void setIdcli(int idcli) {
        this.idcli = idcli;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getNumtel() {
        return numtel;
    }

    public void setNumtel(String numtel) {
        this.numtel = numtel;
    }
}