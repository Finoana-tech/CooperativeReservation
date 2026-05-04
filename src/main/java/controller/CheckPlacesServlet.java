package controller;

import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import dao.*;
import model.*;

@WebServlet("/CheckPlacesServlet")
public class CheckPlacesServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idvoit = request.getParameter("idvoit");
        String dateVoyage = request.getParameter("date");
        String idreservCourante = request.getParameter("idreserv");

        ReservationDAO resDAO = new ReservationDAO();
        VoitureDAO voitDAO = new VoitureDAO();
        PlaceDAO placeDAO = new PlaceDAO();

        // Récupérer toutes les places occupées dans la table RESERVER pour cette date
        // précise
        List<Integer> occupees = resDAO.getPlacesOccupeesParDate(idvoit, dateVoyage);

        // Identifier les places du client actuel (utile pour le mode modification)
        List<Integer> placesDuClient = new ArrayList<>();
        if (idreservCourante != null && !idreservCourante.isEmpty() && !idreservCourante.equals("null")) {
            List<Reservation> mesRes = resDAO.getAllByCodeReserv(idreservCourante);
            for (Reservation r : mesRes) {
                placesDuClient.add(r.getPlace());
            }
        }

        // Récupérer le nombre total de places de la voiture
        Voiture v = voitDAO.getById(idvoit);
        int total = (v != null) ? v.getNbrplace() : 0;

        StringBuilder html = new StringBuilder();

        String baseStyle = "display: inline-flex; align-items: center; justify-content: center; " +
                "width: 75px; height: 50px; margin: 8px; border-radius: 6px; " +
                "font-size: 0.85rem; font-weight: 600; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1);";

        for (int i = 1; i <= total; i++) {
            String nomPlace = placeDAO.getNomPlaceSpecifique(idvoit, i);
            if (nomPlace == null || nomPlace.isEmpty()) {
                nomPlace = "Place " + i;
            }

            // CAS 1 : Place déjà réservée par CE client (BLEUE)
            if (placesDuClient.contains(i)) {
                html.append("<div class='seat selected-blue' ")
                        .append("data-num='").append(i).append("' ")
                        .append("onclick='selectSeat(this, ").append(i).append(")' ")
                        .append("style='").append(baseStyle)
                        .append(" background-color: #0d6efd; color: white; cursor: pointer; border: 2px solid #004299;' ")
                        .append("title='Votre sélection actuelle'>")
                        .append("<span style='line-height: 1.2;'>").append(nomPlace).append("</span>")
                        .append("</div>");
            }
            // CAS 2 : Place occupée par un autre client (GRISE)
            else if (occupees.contains(i)) {
                html.append("<div class='seat occupied-grey' ")
                        .append("data-num='").append(i).append("' ")
                        .append("style='").append(baseStyle)
                        .append(" background-color: #e9ecef; color: #adb5bd; cursor: not-allowed; border: 1px solid #dee2e6; pointer-events: none;' ")
                        .append("title='Place déjà réservée'>")
                        .append("<span style='line-height: 1.2;'>").append(nomPlace).append("</span>")
                        .append("</div>");
            }
            // CAS 3 : La place est LIBRE (BLANCHE)
            else {
                html.append("<div class='seat available-white' ")
                        .append("data-num='").append(i).append("' ")
                        .append("onclick='selectSeat(this, ").append(i).append(")' ")
                        .append("style='").append(baseStyle)
                        .append(" background-color: #ffffff; color: #1a3a5f; cursor: pointer; border: 2px solid #1a3a5f;' ")
                        .append("title='Disponible'>")
                        .append("<span style='line-height: 1.2;'>").append(nomPlace).append("</span>")
                        .append("</div>");
            }
        }

        response.setContentType("text/html;charset=UTF-8");
        response.getWriter().write(html.toString());
    }
}