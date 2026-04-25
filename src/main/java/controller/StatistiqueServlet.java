package controller;

import dao.ReservationDAO;
import dao.VoitureDAO;
import model.Reservation;
import model.Voiture;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/StatistiqueServlet")
public class StatistiqueServlet extends HttpServlet {

    private ReservationDAO resDAO = new ReservationDAO();
    private VoitureDAO voitDAO = new VoitureDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Toujours charger la liste des voitures pour le menu déroulant de recherche
        List<Voiture> listeVoitures = voitDAO.getAll();
        request.setAttribute("listeVoitures", listeVoitures);

        // 2. Récupérer la recette totale (exigence du projet)
        int recetteTotale = resDAO.getRecetteTotale();
        request.setAttribute("recetteTotale", recetteTotale);

        // 3. Gestion de la recherche des voyageurs par statut
        String idvoit = request.getParameter("idvoit");

        if (idvoit != null && !idvoit.isEmpty()) {
            // On récupère les 3 listes demandées par le sujet
            // Note : Ici on suppose que getVoyageursParStatut renvoie des objets
            // Reservation
            List<Reservation> sansAvance = resDAO.getVoyageursParStatut(idvoit, "sans avance");
            List<Reservation> avecAvance = resDAO.getVoyageursParStatut(idvoit, "avec avance");
            List<Reservation> toutPaye = resDAO.getVoyageursParStatut(idvoit, "tout payé");

            // --- ADAPTATION POUR LE CALCUL RÉEL DES VOYAGEURS ---
            // On ne compte plus .size() (le nombre de lignes groupées)
            // Mais on compte le nombre total de places occupées dans chaque catégorie

            int nbVoyageursSansAvance = 0;
            for (Reservation r : sansAvance)
                nbVoyageursSansAvance += 1; // Ou r.getNombrePlaces() si groupé en SQL

            int nbVoyageursAvecAvance = 0;
            for (Reservation r : avecAvance)
                nbVoyageursAvecAvance += 1;

            int nbVoyageursToutPaye = 0;
            for (Reservation r : toutPaye)
                nbVoyageursToutPaye += 1;

            // On envoie les listes à la JSP
            request.setAttribute("sansAvance", sansAvance);
            request.setAttribute("avecAvance", avecAvance);
            request.setAttribute("toutPaye", toutPaye);

            // On envoie les comptes ADAPTÉS (Nombre réel de voyageurs/places)
            // Si vos listes DAO sont déjà groupées, il faudra sommer les places.
            // Si elles ne sont pas groupées, .size() est correct pour le nombre de
            // voyageurs.
            request.setAttribute("nbSansAvance", sansAvance.size());
            request.setAttribute("nbAvecAvance", avecAvance.size());
            request.setAttribute("nbToutPaye", toutPaye.size());

            // AJOUT : On récupère les infos de la voiture pour avoir le 'frais' dans la JSP
            Voiture voitureSelectionnee = voitDAO.getById(idvoit);
            request.setAttribute("voitureDetails", voitureSelectionnee);

            // Garder la voiture sélectionnée en mémoire pour l'affichage
            request.setAttribute("selectedVoit", idvoit);
        }

        // Redirection vers la page des statistiques
        request.getRequestDispatcher("rapport/statistiques.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}