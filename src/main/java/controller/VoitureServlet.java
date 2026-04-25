package controller;

import dao.VoitureDAO;
import model.Voiture;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/VoitureServlet")
public class VoitureServlet extends HttpServlet {
    private VoitureDAO voitDAO = new VoitureDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String search = request.getParameter("search");

        // 1. Logique de Suppression
        if ("delete".equals(action)) {
            // On récupère 'id' car c'est ce que notre fonction JS envoie dans l'URL
            String idvoit = request.getParameter("id");

            boolean success = voitDAO.supprimer(idvoit);

            if (success) {
                response.sendRedirect("VoitureServlet?msg=La voiture a ete supprimee avec succes");
            } else {
                response.sendRedirect("VoitureServlet?msg=Erreur lors de la suppression");
            }
            return;
        }

        // 2. Logique d'affichage et de recherche
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

            boolean result = false;
            if ("update".equals(action)) {
                result = voitDAO.modifier(v);
                message = result ? "Voiture modifiee avec succes" : "Erreur lors de la modification";
            } else {
                result = voitDAO.ajouter(v);
                message = result ? "Voiture ajoutee avec succes" : "Erreur lors de l'ajout";
            }
        } catch (NumberFormatException e) {
            message = "Erreur : Veuillez saisir des nombres valides pour les places et frais";
        } catch (Exception e) {
            e.printStackTrace();
            message = "Une erreur inattendue est survenue";
        }

        // Redirection vers la liste avec le message pour le script JS
        response.sendRedirect("VoitureServlet?msg=" + message);
    }
}