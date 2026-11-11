// =====================================================================
// INSTITUT 2iE - MN2 - TP 01 : Calculer une energie avec Scilab
// Etudiante : BAYALA Grace Orlane - Matricule 20230225
// =====================================================================
clear; clc;

// ---------------------------------------------------------------------
// 1. Methode des trapezes (pas eventuellement inegaux)
// ---------------------------------------------------------------------
function q = trapezes(t, y)
    // Controles de taille (fournis)
    if length(t) <> length(y) then error("t et y de longueurs differentes."); end
    if length(t) < 2 then error("Au moins deux points sont necessaires."); end
    n = length(t) - 1;
    q = 0;
    for i = 1:n
        h = t(i+1) - t(i);
        if h <= 0 then error("Temps non croissants."); end
        // TODO 1 : aire du trapeze sur [t(i), t(i+1)]
        aire = h * (y(i) + y(i+1)) / 2;
        // TODO 2 : ajouter aire au total
        q = q + aire;
    end
endfunction

// ---------------------------------------------------------------------
// 2. Methode de Simpson (pas egaux, n pair)
// ---------------------------------------------------------------------
function q = simpson(t, y)
    // Controles de taille et de croissance (fournis)
    if length(t) <> length(y) then error("t et y de longueurs differentes."); end
    if length(t) < 3 then error("Simpson exige au moins trois points."); end
    n = length(t) - 1;
    if or(diff(t) <= 0) then error("Temps non croissants."); end

    // TODO 3 : n est impair
    if modulo(n, 2) == 1 then error("Simpson exige n pair."); end

    h = t(2) - t(1);
    echelle = 1;
    if abs(h) > 1 then echelle = abs(h); end
    tol = 1e-10 * echelle;
    for i = 2:n
        pas = t(i+1) - t(i);
        // TODO 4 : comparer pas et h avec tol
        if abs(pas - h) > tol then error("Simpson exige des pas egaux."); end
    end

    q = y(1) + y(n+1);
    for i = 2:n
        if modulo(i, 2) == 0 then
            // TODO 5 : contribution de poids 4
            q = q + 4 * y(i);
        else
            // TODO 5 : contribution de poids 2
            q = q + 2 * y(i);
        end
    end
    // TODO 5 : appliquer h/3 a la somme ponderee
    q = q * h / 3;
endfunction

// ---------------------------------------------------------------------
// 3. Verification sur un cas connu : P(t) = 10 + 4t - t^2
// ---------------------------------------------------------------------
tt = [0 1 2 3 4];
PP = [10 13 14 13 10];
T4 = trapezes(tt, PP);
S4 = simpson(tt, PP);
mprintf("--- Cas test ---\n");
mprintf("Trapezes : %.6f J (attendu 50)\n", T4);
mprintf("Simpson  : %.6f J (attendu %.6f = 152/3)\n", S4, 152/3);
if abs(T4 - 50) > 1e-10 then error("Test trapezes echoue."); end
if abs(S4 - 152/3) > 1e-10 then error("Test Simpson echoue."); end

// Trapezes sur pas inegaux : t = [0 1 3], y = [0 2 2] -> 1 + 4 = 5
if abs(trapezes([0 1 3], [0 2 2]) - 5) > 1e-12 then
    error("Test trapezes pas inegaux echoue.");
end

// Simpson doit refuser les pas inegaux et un n impair
ok1 = %f; ok2 = %f;
try
    simpson([0 1 3 4 5], [1 2 3 4 5]);
catch
    ok1 = %t;
end
try
    simpson([0 1 2 3], [1 2 3 4]);
catch
    ok2 = %t;
end
if ~ok1 then error("Simpson aurait du refuser les pas inegaux."); end
if ~ok2 then error("Simpson aurait du refuser n impair."); end
mprintf("Refus de Simpson (pas inegaux, n impair) : OK\n\n");

// ---------------------------------------------------------------------
// 4. Energie de la pompe
// ---------------------------------------------------------------------
tmin = [0 10 20 30 40];
Pkw  = [2.0 2.6 3.0 2.5 1.9];
th = zeros(1, length(tmin));
for i = 1:length(tmin)
    // TODO 6 : minutes -> heures
    th(i) = tmin(i) / 60;
end
ET = trapezes(th, Pkw);
ES = simpson(th, Pkw);
ecart = abs(ET - ES);

mprintf("--- Pompe (40 min) ---\n");
mprintf("Trapezes T4 = %.6f kWh\n", ET);
mprintf("Simpson  S4 = %.6f kWh\n", ES);
mprintf("Ecart |T4 - S4| = %.6f kWh\n", ecart);

// Incertitude maximale liee aux lectures de puissance (0,1 kW sur 40 min)
incert = 0.1 * 40 / 60;
mprintf("Incertitude des lectures = %.6f kWh\n", incert);
if ecart < incert then
    mprintf("L'ecart entre methodes est inferieur a l'incertitude des lectures.\n");
else
    mprintf("L'ecart entre methodes depasse l'incertitude des lectures.\n");
end

// ---------------------------------------------------------------------
// 5. Conclusion (4 lignes)
// ---------------------------------------------------------------------
// TODO 7
// Energie estimee (avec unite) : environ 1,68 kWh (T4 = 1,675 kWh ; S4 = 1,683 kWh), soit 1,68 +/- 0,07 kWh.
// Ecart entre les deux methodes : |T4 - S4| = 0,0083 kWh, tres faible (environ 0,5 %).
// Comparaison avec l'incertitude des lectures : l'ecart (0,008 kWh) est environ 8 fois plus petit que l'incertitude 0,1 x 40/60 = 0,067 kWh ; on ne peut donc pas affirmer que Simpson est plus juste.
// Limite des releves espaces de 10 min : seulement 5 points, des variations plus rapides de la puissance entre deux releves peuvent etre manquees ; l'energie reste donc une estimation.
