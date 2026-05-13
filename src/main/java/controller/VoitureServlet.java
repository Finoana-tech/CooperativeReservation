package controller;

import dao.VoitureDAO;
import model.Voiture;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/VoitureServlet")
public class VoitureServlet extends HttpServlet {

    private VoitureDAO voitDAO = new VoitureDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String search = request.getParameter("search");

        if ("delete".equals(action)) {
            String idvoit = request.getParameter("id");
            boolean success = voitDAO.supprimer(idvoit);
            if (success) {
                response.sendRedirect("VoitureServlet?msg=La voiture a ete supprimee avec succes");
            } else {
                response.sendRedirect("VoitureServlet?msg=Erreur lors de la suppression");
            }
            return;
        }

        List<Voiture> liste;
        if (search != null && !search.trim().isEmpty()) {
            liste = voitDAO.rechercher(search);
        } else {
            liste = voitDAO.getAll();
        }
        request.setAttribute("voitures", liste);
        request.getRequestDispatcher("voiture/voitureList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        Voiture v = new Voiture();
        v.setIdvoit(request.getParameter("idvoit"));
        v.setDesign(request.getParameter("design"));
        v.setType(request.getParameter("type"));

        String message = "";

        try {
            v.setNbrplace(Integer.parseInt(request.getParameter("nbrplace")));
            v.setFrais(Integer.parseInt(request.getParameter("frais")));

            if ("update".equals(action)) {
                // Mise à jour → on ne vérifie pas l'ID (car il ne change pas)
                boolean result = voitDAO.modifier(v);
                message = result ? "Voiture modifiee avec succes" : "Erreur lors de la modification";

            } else {
                // ==================== AJOUT ====================
                // Vérification lors de l'ajout si l'idvoit est deja existe
                if (voitDAO.idExiste(v.getIdvoit())) {
                    message = "ERREUR : L'Identifiant de voiture '" + v.getIdvoit()
                            + "' existe déjà. Veuillez saisir un autre.";
                } else {
                    boolean result = voitDAO.ajouter(v);
                    message = result ? "Voiture ajoutee avec succes" : "Erreur lors de l'ajout";
                }
            }
        } catch (NumberFormatException e) {
            message = "Erreur : Veuillez saisir des nombres valides pour les places et frais";
        } catch (Exception e) {
            e.printStackTrace();
            message = "Une erreur inattendue est survenue";
        }

        // Redirection avec encodage UTF-8
        response.sendRedirect("VoitureServlet?msg=" + URLEncoder.encode(message, StandardCharsets.UTF_8));
    }
}