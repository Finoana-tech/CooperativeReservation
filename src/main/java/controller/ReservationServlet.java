package controller;

import dao.*;
import model.*;
import java.io.IOException;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ReservationServlet")
public class ReservationServlet extends HttpServlet {

    private ReservationDAO resDAO = new ReservationDAO();
    private ClientDAO cliDAO = new ClientDAO();
    private VoitureDAO voitDAO = new VoitureDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String message = "";

        try {
            if ("create".equals(action) || "update".equals(action)) {
                // 1. Détermination du code de réservation
                String idReserv = ("update".equals(action)) ? request.getParameter("idreserv")
                        : resDAO.genererProchainCodeReserv();

                String idVoit = request.getParameter("idvoit");
                String placeParam = request.getParameter("place");

                if (placeParam == null || placeParam.isEmpty()) {
                    response.sendRedirect("ReservationServlet?action=list&msg=Erreur : Aucune place sélectionnée");
                    return;
                }

                String[] tabPlaces = placeParam.split(",");
                String payment = request.getParameter("payment");
                int idCli = Integer.parseInt(request.getParameter("idcli"));
                Date dateVoyage = Date.valueOf(request.getParameter("date_voyage"));

                // 2. Logique de calcul et CONTRAINTE DE L'AVANCE
                int montantTotalAEnregistrer = 0;
                Voiture v = voitDAO.getById(idVoit);
                int fraisTotalReel = v.getFrais() * tabPlaces.length;

                if ("tout payé".equalsIgnoreCase(payment)) {
                    montantTotalAEnregistrer = fraisTotalReel;
                } else if ("sans avance".equalsIgnoreCase(payment)) {
                    montantTotalAEnregistrer = 0;
                } else {
                    // Cas "avec avance"
                    montantTotalAEnregistrer = Integer.parseInt(request.getParameter("montant_avance"));

                    // --- ADAPTATION DE LA CONTRAINTE ---
                    if (montantTotalAEnregistrer > fraisTotalReel) {
                        // On redirige avec un message d'erreur qui sera intercepté par scripts.js
                        message = "Erreur : Le montant de l'avance (" + montantTotalAEnregistrer +
                                " Ar) dépasse le montant total des frais (" + fraisTotalReel + " Ar).";
                        response.sendRedirect("ReservationServlet?action=list&msg=" + message);
                        return;
                    }
                }

                // 3. Gestion de la modification (Update)
                if ("update".equals(action)) {
                    resDAO.supprimerToutesPlaces(idReserv);
                }

                Timestamp dateCreation = new Timestamp(System.currentTimeMillis());
                boolean allSuccess = true;

                // 4. Insertion ligne par ligne
                int montantParLigne = montantTotalAEnregistrer / tabPlaces.length;

                for (String pNum : tabPlaces) {
                    Reservation r = new Reservation();
                    r.setIdreserv(idReserv);
                    r.setIdvoit(idVoit);
                    r.setIdcli(idCli);
                    r.setPlace(Integer.parseInt(pNum.trim()));
                    r.setDateReserv(dateCreation);
                    r.setDateVoyage(dateVoyage);
                    r.setPayment(payment);
                    r.setMontantAvance(montantParLigne);

                    if (!resDAO.ajouter(r)) {
                        allSuccess = false;
                    }
                }

                message = allSuccess ? "Réservation enregistrée avec succès" : "Erreur lors de l'enregistrement";
                response.sendRedirect("ReservationServlet?action=list&msg=" + message);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ReservationServlet?action=list&msg=Erreur système : " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null)
            action = "list";

        // 1. Navigation : Formulaire d'ajout
        if ("add".equals(action)) {
            request.getRequestDispatcher("reservation/reservationCreate.jsp").forward(request, response);
            return;
        }

        // 2. Navigation : Formulaire de modification
        if ("edit".equals(action)) {
            request.getRequestDispatcher("reservation/reservationUpdate.jsp").forward(request, response);
            return;
        }

        // 3. Action : Suppression / Annulation
        if ("delete".equals(action)) {
            String codeReserv = request.getParameter("id"); // Récupère l'id passé par scripts.js
            if (resDAO.supprimerToutesPlaces(codeReserv)) {
                response.sendRedirect("ReservationServlet?action=list&msg=La réservation a été annulée");
            } else {
                response.sendRedirect("ReservationServlet?action=list&msg=Erreur lors de l'annulation");
            }
            return;
        }

        // 4. Action par défaut : Liste
        List<Reservation> reservations = resDAO.getAll();
        int recetteTotale = resDAO.getRecetteTotale();

        request.setAttribute("reservations", reservations);
        request.setAttribute("recetteTotale", recetteTotale);

        request.getRequestDispatcher("reservation/reservationList.jsp").forward(request, response);
    }
}