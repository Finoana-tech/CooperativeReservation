/**
 * Fonction pour charger et afficher les places libres
 * d'une voiture à une date donnée.
 */
function chargerPlaces() {
    // Récupération des éléments du DOM
    const idvoit = document.getElementById("idvoit").value;
    const date = document.getElementById("dateVoyage").value;
    const grid = document.getElementById("seatGrid");
    const msg = document.getElementById("emptyMessage");

    // Vérification : on ne lance la recherche que si les deux champs sont remplis
    if (idvoit !== "" && date !== "") {
        
        // Préparation de l'interface
        msg.style.display = "none";
        grid.style.display = "grid";
        grid.innerHTML = `
            <div class="text-center w-100" style="grid-column: span 4; padding: 20px;">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Chargement...</span>
                </div>
                <p class="mt-2">Vérification des disponibilités...</p>
            </div>`;

        // Appel AJAX vers le Servlet (Chemin relatif vers la racine du projet)
        // Note : On remonte d'un niveau (../) car le JS est dans un sous-dossier /js/
        const url = `../CheckPlacesServlet?idvoit=${encodeURIComponent(idvoit)}&date=${encodeURIComponent(date)}`;

        fetch(url)
            .then(response => {
                if (!response.ok) {
                    throw new Error("Erreur réseau lors de la récupération des places.");
                }
                return response.text();
            })
            .then(html => {
                // Injection du code HTML généré par le Servlet
                grid.innerHTML = html;
                
                // IMPORTANT : Pour la vue "Consultation", on désactive l'interaction
                // On retire l'attribut onclick et on change le curseur pour chaque rectangle
                const seats = grid.querySelectorAll('.seat');
                
                if (seats.length === 0) {
                    grid.innerHTML = "<div class='text-center w-100' style='grid-column: span 4;'>Aucune donnée de place trouvée pour cette voiture.</div>";
                }

                seats.forEach(s => {
                    s.onclick = null; // Désactive la fonction selectSeat du servlet
                    s.style.cursor = "default"; // Curseur normal au lieu de la main
                });
            })
            .catch(err => {
                grid.innerHTML = `<div class="alert alert-danger w-100" style="grid-column: span 4;">
                                    ${err.message}
                                  </div>`;
                console.error("Erreur AJAX :", err);
            });
            
    } else {
        // Si les champs sont vidés, on réinitialise l'affichage
        grid.style.display = "none";
        msg.style.display = "block";
    }
}