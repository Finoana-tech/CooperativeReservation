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

        List<Voiture> listeVoitures = voitDAO.getAll();
        request.setAttribute("listeVoitures", listeVoitures);

        int recetteTotale = resDAO.getRecetteTotale();
        request.setAttribute("recetteTotale", recetteTotale);

        String idvoit = request.getParameter("idvoit");

        if (idvoit != null && !idvoit.isEmpty()) {
            List<Reservation> sansAvance = resDAO.getVoyageursParStatut(idvoit, "sans avance");
            List<Reservation> avecAvance = resDAO.getVoyageursParStatut(idvoit, "avec avance");
            List<Reservation> toutPaye = resDAO.getVoyageursParStatut(idvoit, "tout payé");

            int nbVoyageursSansAvance = 0;
            for (Reservation r : sansAvance)
                nbVoyageursSansAvance += 1;

            int nbVoyageursAvecAvance = 0;
            for (Reservation r : avecAvance)
                nbVoyageursAvecAvance += 1;

            int nbVoyageursToutPaye = 0;
            for (Reservation r : toutPaye)
                nbVoyageursToutPaye += 1;
            request.setAttribute("sansAvance", sansAvance);
            request.setAttribute("avecAvance", avecAvance);
            request.setAttribute("toutPaye", toutPaye);
            request.setAttribute("nbSansAvance", sansAvance.size());
            request.setAttribute("nbAvecAvance", avecAvance.size());
            request.setAttribute("nbToutPaye", toutPaye.size());

            Voiture voitureSelectionnee = voitDAO.getById(idvoit);
            request.setAttribute("voitureDetails", voitureSelectionnee);
            request.setAttribute("selectedVoit", idvoit);
        }
        request.getRequestDispatcher("rapport/statistiques.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}