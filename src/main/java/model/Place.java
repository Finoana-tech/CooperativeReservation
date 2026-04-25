package model;

public class Place {
    private String idvoit; // Clé étrangère vers la voiture
    private int place; // Numéro de la place (1, 2, 3...)
    private String occupation; // 'oui' ou 'non'
    private String nomPlace; // Désignation précise (ex: "Chauffeur", "Banc 2")

    // Constructeur par défaut
    public Place() {
    }

    // Constructeur complet (Adapté à ta table SQL)
    public Place(String idvoit, int place, String occupation, String nomPlace) {
        this.idvoit = idvoit;
        this.place = place;
        this.occupation = occupation;
        this.nomPlace = nomPlace;
    }

    // Getters et Setters
    public String getIdvoit() {
        return idvoit;
    }

    public void setIdvoit(String idvoit) {
        this.idvoit = idvoit;
    }

    public int getPlace() {
        return place;
    }

    public void setPlace(int place) {
        this.place = place;
    }

    public String getOccupation() {
        return occupation;
    }

    public void setOccupation(String occupation) {
        this.occupation = occupation;
    }

    public String getNomPlace() {
        return nomPlace;
    }

    public void setNomPlace(String nomPlace) {
        this.nomPlace = nomPlace;
    }

    /**
     * Méthode utilitaire pour vérifier si la place est libre
     */
    public boolean isLibre() {
        return "non".equalsIgnoreCase(this.occupation);
    }
}