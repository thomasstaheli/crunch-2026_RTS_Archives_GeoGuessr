import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

Window {
    id: root
    width: 1200
    height: 800
    visible: true
    title: "Time-Travel GeoGuessr"

    property bool gameStarted: false
    property string playerName: ""
    property int currentRoundIndex: 0
    property int totalScore: 0
    property bool isGameOver: false

    // Logique du jeu
    readonly property var gameData: [
        {
            year: 1910, x: 519.0, y: 352.0, file: "img/yverdon_1_1910.png",
            description: "Dans les années 1910, La rue de la plaine n’était pas envahie par les voitures comme nous le voyons de nos jours."
        },
        {
            year: 1970, x: 465.0, y: 308.0, file: "img/yverdon_2_1970.png",
            description: "Dans les années 70 la rue du Lac était ouvert aux automobilistes. À droite, on devine le magasin 'Réunis' actuellement la Placette2, à droite l'Hôtel de Londres actuellement le 'Seven Café'."
        },
        {
            year: 1910, x: 501.0, y: 286.0, file: "img/yverdon_3_1910.png",
            description: "Carte postale colorisée du début des années 1910. Les omnibus jaunes semblent avoir des moteurs mais disposent encore des roues en bois."
        },
        {
            year: 1910, x: 458.0, y: 293.0, file: "img/yverdon_4_1910.png",
            description: "Le pont de Gleyres reliait déjà les deux rives de la Thielle. Il n’était pas encore le théâtre d’encombrement de la circulation."
        },
        {
            year: 1940, x: 443.0, y: 319.0, file: "img/yverdon_5_1940.png",
            description: "Cette image montre un rassemblement militaire à la caserne d’Yverdon pendant la deuxième guerre mondiale."
        },
        {
            year: 1920, x: 503.0, y: 285.0, file: "img/yverdon_6_1920.png",
            description: "On retrouve, ici, le casino d’Yverdon, un bâtiment emblématique de la ville. Ce cliché date des années 20."
        },
        {
            year: 1970, x: 635.0, y: 501.0, file: "img/yverdon_7_1970.png",
            description: "Ce lieu est à l’origine du nom de la ville. Nous voyons ici le grand hôtel et centre thermal d'Yverdon-les-Bains."
        },
        {
            year: 1950, x: 618.0, y: 175.0, file: "img/yverdon_8_1950.png",
            description: "Un bâteau mythique d'Yverdon-les-Bains."
        }
    ]

    // 1. LA CARTE (Arrière-plan)
    Image {
        id: mainMap
        anchors.fill: parent
        source: "img/" + control.value + ".png"
        fillMode: Image.PreserveAspectCrop
        visible: gameStarted

        // Zone d'interaction pour placer le point
        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => {
                pin.x = mouse.x - pin.width/2
                pin.y = mouse.y - pin.height
                pin.visible = true
                // console.info("User cliqued place :   x = " + pin.x + " |  y = " + pin.y)
            }
        }

        Image {
            id: pin
            source: "img/pin.png" // Assure-toi que ce fichier existe et est dans ton CMake
            width: 50             // Taille à adapter selon ton image
            height: 50
            visible: false

            // Empêche la déformation si l'image n'est pas carrée
            fillMode: Image.PreserveAspectFit

            // Améliore le rendu lors du redimensionnement
            smooth: true

            // Optionnel : petite animation pour que le pin "tombe" sur la carte
            Behavior on y {
                NumberAnimation { duration: 200; easing.type: Easing.OutBounce }
            }
        }

        // Le Marqueur de la réponse correcte
        Image {
            id: targetPin
            source: "img/correct_pin.png"
            width: 50; height: 50
            visible: false // Caché jusqu'à la validation
            fillMode: Image.PreserveAspectFit
            z: 11 // Juste au-dessus de ton pin

            // Sa position est liée aux données du round actuel
            x: gameData[currentRoundIndex].x
            y: gameData[currentRoundIndex].y
        }

        // La ligne entre les deux points
        Canvas {
            id: lineCanvas
            anchors.fill: parent
            visible: false
            z: 10 // Entre la carte et les pins

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                // Style de la ligne
                ctx.lineWidth = 4;
                ctx.strokeStyle = "#ff3366"; // Ton rose
                ctx.setLineDash([10, 8]); // Ligne en pointillés style GeoGuessr

                // Dessin de la ligne
                ctx.beginPath();
                // Point de départ (milieu de ton pin)
                ctx.moveTo(pin.x + pin.width / 2, pin.y + pin.height / 2);
                // Point d'arrivée (milieu du targetPin)
                ctx.lineTo(targetPin.x + targetPin.width / 2, targetPin.y + targetPin.height / 2);
                ctx.stroke();
            }
        }
    }

    // 2. SLIDER TEMPOREL (Haut)
    Item {
        id: sliderContainer
        width: parent.width * 0.8
        height: 140 // Augmenté légèrement pour laisser de la place au badge
        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        visible: gameStarted

        // 1. LA SLIDE BAR
        Slider {
            id: control
            width: parent.width
            height: 50
            anchors.top: parent.top

            from: 1900
            to: 2020
            stepSize: 10
            snapMode: Slider.SnapAlways
            value: 1900

            background: Rectangle {
                x: control.leftPadding
                y: control.topPadding + control.availableHeight / 2 - height / 2
                width: control.availableWidth
                height: 16
                radius: 8
                color: "#f0f0f0"

                // EFFET DE FADE (Blanc vers Rose)
                Rectangle {
                    id: progressRect
                    width: control.visualPosition * parent.width
                    height: parent.height
                    radius: 8
                    clip: true

                    Rectangle {
                        width: control.availableWidth
                        height: parent.height
                        radius: 8
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#ffffff" }
                            GradientStop { position: 1.0; color: "#ff3366" }
                        }
                    }
                }
            }

            handle: Rectangle {
                x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
                y: control.topPadding + control.availableHeight / 2 - height / 2
                implicitWidth: 38
                implicitHeight: 38
                radius: 19
                color: "#ffffff"

                Rectangle {
                    anchors.centerIn: parent
                    width: 24; height: 24; radius: 12
                    color: "#ff3366"
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 0.8
                    shadowVerticalOffset: 3
                    shadowColor: "#30000000"
                }
            }
        }

        // 2. LE BADGE DE LA DATE (Rectangle rose + texte blanc)
        Rectangle {
            id: dateBadge
            anchors.top: control.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            // Taille du badge
            width: 140
            height: 60
            radius: height / 2 // Effet pilule
            color: "#ff3366"   // Ton rose thématique

            // Ombre pour décoller le badge de la carte
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 1.0
                shadowVerticalOffset: 4
                shadowColor: "#40000000"
            }

            Text {
                id: yearLabel
                anchors.centerIn: parent // Centre parfaitement le texte dans le rectangle
                text: control.value
                font.pixelSize: 32
                font.bold: true
                color: "white" // Texte blanc sur fond rose
            }
        }
    }

    // --- 1. LE DIMMER (Fond qui assombrit la carte quand le panneau est ouvert) ---
    Rectangle {
        id: dimmer
        anchors.fill: parent
        color: "black"
        opacity: sidePanel.isOpen ? 0.5 : 0 // Devient semi-transparent
        z: 15 // Entre la carte et le panneau
        visible: opacity > 0

        // Transition douce pour l'assombrissement
        Behavior on opacity { NumberAnimation { duration: 400 } }

        // Cliquer sur le fond sombre ferme aussi le panneau
        MouseArea {
            anchors.fill: parent
            onClicked: sidePanel.isOpen = false
        }
    }

    // --- 2. LE PANNEAU LATÉRAL GÉANT (90% de la largeur) ---
    Rectangle {
        id: sidePanel
        property bool isOpen: false

        // Calcul de la largeur : 90% de la fenêtre
        width: parent.width * 0.9
        height: parent.height
        x: isOpen ? 0 : -width
        color: "white"
        z: 20
        visible: gameStarted

        Behavior on x {
            NumberAnimation { duration: 500; easing.type: Easing.OutQuint }
        }

        // --- CONTENU ---
        Column {
            anchors.fill: parent
            anchors.margins: 40 // Plus de marges car le panneau est grand
            spacing: 30

            // Ligne de titre avec bouton fermer
            Row {
                width: parent.width
                Text {
                    text: "Archives Historiques - " + "Yverdon-les-bains"
                    font.pixelSize: 36
                    font.bold: true
                    color: "#ff3366"
                    width: parent.width - 50
                }

                // Petite croix pour fermer en haut à droite
                Text {
                    text: "✕"
                    font.pixelSize: 30
                    color: "#999"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: sidePanel.isOpen = false
                    }
                }
            }

            // Grande image d'archive centrale
            Rectangle {
                width: parent.width
                height: parent.height * 0.5
                radius: 15
                clip: true
                color: "#f0f0f0"

                Image {
                    id: archiveImage
                    anchors.fill: parent

                    // --- LOGIQUE DYNAMIQUE ---
                    // On utilise l'index actuel pour récupérer l'année dans le tableau
                    // et construire le nom du fichier (ex: yverdon_1_1900.png)
                    source: "img/yverdon_" + (currentRoundIndex + 1) + "_" + gameData[currentRoundIndex].year + ".png"

                    fillMode: Image.PreserveAspectFit

                    // Petite transition pour que l'image ne change pas brutalement
                    Behavior on source {
                        SequentialAnimation {
                            NumberAnimation { target: archiveImage; property: "opacity"; to: 0; duration: 100 }
                            PropertyAction { target: archiveImage; property: "source" }
                            NumberAnimation { target: archiveImage; property: "opacity"; to: 1; duration: 200 }
                        }
                    }
                }
            }

            Text {
                id: instructionOrDescription
                text: scorePopup.visible ?
                      gameData[currentRoundIndex].description :
                      "Voici l'archive, à vous de deviner la date de cette archive (curseur) et ensuite de placer l'endroit exact de cette archive sur la carte (clic gauche)"

                width: parent.width
                font.pixelSize: 20
                lineHeight: 1.4
                wrapMode: Text.WordWrap
                color: scorePopup.visible ? "#ff3366" : "#444" // Devient rose quand c'est la description pour attirer l'oeil

                // Animation fluide pour le changement de texte
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }

        // --- LE BOUTON VALIDER (Tout en bas du panneau) ---
        Button {
            id: validateButton
            text: "Valider"
            width: parent.width - 40
            height: 70
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter

            // 1. On force l'activation du survol
            hoverEnabled: true

            // 3. LE FOND (C'est ici qu'on bloque le style par défaut)
            background: Rectangle {
                id: bgRect
                // On définit les couleurs pour chaque état
                readonly property color colorNormal: "#ff3366"
                readonly property color colorHover: "#d62b55"  // Un rose plus foncé
                readonly property color colorPressed: "#a82243" // Encore plus foncé

                // Logique de changement de couleur
                color: validateButton.pressed ? colorPressed :
                       (validateButton.hovered ? colorHover : colorNormal)

                radius: 35
                border.color: "white"
                border.width: 2

                // Petite ombre pour le relief
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 0.5
                    shadowVerticalOffset: 3
                    shadowColor: "#40000000"
                }

                // Transition fluide pour ne pas que ça flashe
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            // 4. LE TEXTE
            contentItem: Text {
                text: validateButton.text
                font.pixelSize: 24
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                // Effet de zoom très léger au survol
                scale: validateButton.hovered ? 1.03 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
            }

            onClicked: {
                if (!pin.visible) return;

                dateComparisonText.text = "Votre choix : " + Math.round(control.value);
                dateResultDetail.text = "Réponse : " + gameData[currentRoundIndex].year;

                // On récupère la cible actuelle via l'index
                let currentTarget = gameData[currentRoundIndex];

                // On calcule le score via ton Backend C++
                // On compare l'année du Slider (control.value) ET la position du Pin
                let distScore = gameLogic.calculateScore(pin.x, pin.y, currentTarget.x, currentTarget.y);

                // Bonus/Malus pour l'année : si l'année est fausse, on réduit le score
                let yearDiff = Math.abs(Math.round(control.value) - currentTarget.year);
                let finalScore = Math.max(0, distScore - (yearDiff * 20)); // -200 points par année d'écart

                sidePanel.isOpen = false;
                targetPin.visible = true;
                lineCanvas.visible = true;
                lineCanvas.requestPaint(); // Force le dessin de la ligne

                scoreText.text = finalScore + " pts";
                root.totalScore += finalScore;
                scorePopup.visible = true;
            }
        }
    }

    // --- BARRE DE SCORE ---
    Rectangle {
        id: scorePopup
        width: parent.width * 0.9
        height: 120
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        radius: 30
        color: "white"
        border.color: "#ff3366"
        border.width: 3
        z: 2000
        visible: false
        clip: true // Empêche quoi que ce soit de dépasser physiquement de la bulle

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.6
            shadowColor: "#40000000"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 0

            // --- COLONNE 1 : SCORE ---
            Column {
                Layout.fillWidth: true
                Layout.preferredWidth: 1 // Donne 1 part égale
                Layout.alignment: Qt.AlignVCenter
                spacing: 5
                Text {
                    text: "POINTS GAGNÉS"
                    font.pixelSize: 12; font.bold: true; color: "#ff3366"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    id: scoreText
                    text: "0"
                    font.pixelSize: 32; font.bold: true; color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Petit séparateur vertical
            Rectangle { width: 1; height: 60; color: "#f0f0f0"; Layout.alignment: Qt.AlignVCenter }

            // --- COLONNE 2 : DATES ---
            Column {
                Layout.fillWidth: true
                Layout.preferredWidth: 1 // Donne 1 part égale
                Layout.alignment: Qt.AlignVCenter
                spacing: 5

                Text {
                    id: dateDisplay
                    text: "Date Archive"
                    font.pixelSize: 18; font.bold: true; color: "#ff3366"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: dateComparisonText
                    font.pixelSize: 18; font.bold: true; color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    id: dateResultDetail
                    font.pixelSize: 16; font.bold: true; color: "#ff3366"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // Petit séparateur vertical
            Rectangle { width: 1; height: 60; color: "#f0f0f0"; Layout.alignment: Qt.AlignVCenter }

            // --- COLONNE 3 : BOUTON ---
            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: 1 // Donne 1 part égale
                Layout.fillHeight: true

                Button {
                    id: nextButton
                    anchors.centerIn: parent // Centre le bouton dans son tiers d'espace
                    width: Math.min(parent.width * 0.8, 200) // S'adapte si l'écran est petit
                    height: 55
                    text: (currentRoundIndex < gameData.length - 1) ? "ROUND SUIVANT" : "SCORE FINAL"

                    background: Rectangle {
                        color: nextButton.pressed ? "#991F3D" : (nextButton.hovered ? "#CC2954" : "#ff3366")
                        radius: 27
                    }

                    contentItem: Text {
                        text: nextButton.text
                        color: "white"; font.bold: true; font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        scorePopup.visible = false
                        pin.visible = false
                        targetPin.visible = false
                        lineCanvas.visible = false
                        if (currentRoundIndex < gameData.length - 1) {
                            currentRoundIndex++;
                        } else {
                            root.isGameOver = true;
                            root.gameStarted = false;
                        }
                    }
                }
            }
        }
    }

    // --- 3. L'ONGLET DE TIRAGE ---
    Rectangle {
        id: toggleTab
        x: sidePanel.x + sidePanel.width
        y: parent.height / 2 - 50
        width: 40; height: 100
        color: "#ff3366"
        radius: 8
        visible: !sidePanel.isOpen // On le cache quand c'est ouvert pour épurer
        z: 21

        Text {
            anchors.centerIn: parent
            text: "▶"
            color: "white"
            font.bold: true
            font.pixelSize: 24
        }

        MouseArea {
            anchors.fill: parent
            onClicked: sidePanel.isOpen = true
        }
    }

    // --- ÉCRAN DE RÉSULTAT FINAL ---
    Rectangle {
        id: finalScoreScreen
        anchors.fill: parent
        color: "#ffffff" // Fond blanc pour rester dans le thème
        z: 3000
        visible: isGameOver // Ne s'affiche que si isGameOver est vrai

        Column {
            anchors.centerIn: parent
            width: parent.width * 0.7
            spacing: 40

            Text {
                text: "PARTIE TERMINÉE !"
                font.pixelSize: 60
                font.bold: true
                color: "#ff3366"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Bulle de score final
            Rectangle {
                width: 400
                height: 150
                color: "#ff3366"
                radius: 75
                anchors.horizontalCenter: parent.horizontalCenter

                Column {
                    anchors.centerIn: parent
                    Text {
                        text: "SCORE TOTAL"
                        color: "white"
                        font.pixelSize: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: root.totalScore + " pts"
                        color: "white"
                        font.pixelSize: 50
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            Text {
                text: "Bravo " + root.playerName + " !\nTu as terminé les " + gameData.length + " époques d'Yverdon."
                font.pixelSize: 24
                color: "#444"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // BOUTON REJOUER
            Button {
                id: restartButton
                text: "RETOUR AU MENU"
                width: 350
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter
                hoverEnabled: true

                background: Rectangle {
                    color: restartButton.pressed ? "#991F3D" : (restartButton.hovered ? "#CC2954" : "#ff3366")
                    radius: 40
                }

                contentItem: Text {
                    text: restartButton.text
                    color: "white"; font.bold: true; font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }

                onClicked: {

                    // 1. Reset des scores et index
                    root.totalScore = 0;
                    root.currentRoundIndex = 0;

                    // 2. Reset des états de visibilité
                    root.isGameOver = false;   // Cache l'écran de fin
                    root.gameStarted = false;  // Retourne à l'état "Menu"

                    // 3. Nettoyage de la carte (TrÈS IMPORTANT)
                    pin.visible = false;
                    targetPin.visible = false;
                    lineCanvas.visible = false;

                    // 4. Remise du slider à l'année de départ du premier round
                    control.value = control.from;

                    console.log("Jeu réinitialisé, retour au menu.");
                }
            }
        }
    }

    // --- BOUTON RETOUR AU MENU ---
    Rectangle {
        id: backToMenuButton
        width: 60
        height: 60
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20

        color: backToMenuArea.containsMouse ? "#CC2954" : "#ff3366" // Devient plus foncé au survol
        radius: 30
        z: 50 // Doit être au-dessus de la carte mais sous le menu principal

        // N'apparaît que si le jeu a commencé
        visible: gameStarted

        // Petite ombre pour le relief
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.5
            shadowVerticalOffset: 3
            shadowColor: "#40000000"
        }

        // Icône (ici un symbole de maison ou une flèche)
        Text {
            anchors.centerIn: parent
            text: "🏠" // Tu peux aussi mettre "◀" pour une flèche de retour
            font.pixelSize: 30
            color: "white"
        }

        MouseArea {
            id: backToMenuArea
            anchors.fill: parent
            hoverEnabled: true // Pour que le changement de couleur fonctionne
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                // On retourne au menu
                root.gameStarted = false

                // OPTIONNEL : On réinitialise le jeu
                pin.visible = false
                sidePanel.isOpen = false
                console.log("Retour au menu principal")
            }
        }

        // Transition pour que l'icône apparaisse en douceur
        Behavior on visible {
            NumberAnimation { duration: 250 }
        }
    }

    // --- MENU D'ACCUEIL ---
    // --- MENU D'ACCUEIL ---
    Rectangle {
        id: mainMenu
        anchors.fill: parent
        color: "#ffffff" // Fond général blanc
        z: 1000
        visible: !root.gameStarted && !root.isGameOver

        // --- LE BOUCLIER ANTI-CLIC ---
        MouseArea {
            anchors.fill: parent
            // Vide : il intercepte les clics pour qu'ils n'atteignent pas la carte derrière.
        }

        Column {
            anchors.centerIn: parent
            width: parent.width * 0.7 // Un peu plus large pour l'équilibre
            spacing: 40

            // Titre bicolore
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 60
                font.bold: true

                // "TIME-TRAVEL" en Rose, "GEOGUESSR" en Gris Foncé
                text: "TIME-TRAVEL " + "<font color='#333'>GEOGUESSR</font>"
                color: "#ff3366"

                horizontalAlignment: Text.AlignHCenter
            }

            // --- ZONE D'INSERTION DE TEXTE (PRÉNOM) ---
            Column {
                width: parent.width
                spacing: 15

                Text {
                    text: "Entrez votre nom et prénom :";
                    color: "#333"; // Texte en gris foncé pour plus de clarté
                    font.pixelSize: 20;
                    font.bold: true
                }

                TextField {
                    id: nameInput
                    width: parent.width
                    height: 70
                    placeholderText: "Nom Prénom"
                    placeholderTextColor: "#999" // Gris moyen pour le placeholder
                    font.pixelSize: 32
                    color: "#333" // Texte foncé sur fond blanc
                    leftPadding: 25
                    onTextChanged: root.playerName = text

                    background: Rectangle {
                        color: "white"
                        radius: height / 2
                        border.color: "#f0f0f0" // Contour gris clair discret
                        border.width: 3

                        // Effet d'ombre subtile au focus (en gris clair/moyen)
                        layer.enabled: nameInput.activeFocus
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowBlur: 0.4
                            shadowColor: "#40333333"
                        }
                    }
                }
            }

            // --- ZONE DES RÈGLES (Fond clair, texte foncé) ---
            Rectangle {
                width: parent.width
                height: 320 // Légèrement plus haut pour le spacing
                color: "white" // Fond blanc
                radius: 50
                border.color: "#f0f0f0" // Contour gris clair
                border.width: 2

                // Petite ombre pour le relief
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 0.6
                    shadowColor: "#20333333"
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 35
                    spacing: 15

                    Text {
                        text: "Comment jouer :";
                        color: "#ff3366"; // Titre en rose
                        font.bold: true;
                        font.pixelSize: 26
                    }

                    Text {
                        id: rulesText
                        textFormat: Text.RichText // Indispensable pour interpréter les balises <font> et <br>

                        text: "<font color='#ff3366'><b>1.</b></font> Observez l'archive se trouvant dans la petite fenêtre.<br><br>" +
                              "<font color='#ff3366'><b>2.</b></font> Commencez par estimer la date de l'archive en jouant avec le curseur.<br><br>" +
                              "<font color='#ff3366'><b>3.</b></font> Cliquez sur la carte pour placer votre marqueur (clic gauche).<br><br>" +
                              "<font color='#ff3366'><b>4.</b></font> Lorsque tout vous semble correct, appuyez sur le bouton 'Valider'."

                        color: "#333"
                        font.pixelSize: 18
                        width: parent.width - 70
                        wrapMode: Text.WordWrap
                        lineHeight: 1.2
                    }
                }
            }

            // --- BOUTON COMMENCER (Rose affiné) ---
            Button {
                id: startButton
                text: "COMMENCER L'AVENTURE"
                anchors.horizontalCenter: parent.horizontalCenter
                width: 420 // Légèrement plus petit
                height: 80 // Légèrement plus petit
                hoverEnabled: true

                background: Rectangle {
                    color: startButton.pressed ? "#991F3D" : (startButton.hovered ? "#CC2954" : "#ff3366")
                    radius: height / 2 // Forme ovale
                    border.color: "white"
                    border.width: 3
                }

                contentItem: Text {
                    text: startButton.text
                    font.pixelSize: 24
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    // --- ÉTAT AVANT MODIFICATION ---
                    console.log("Démarrage du jeu pour : " + nameInput.text)
                    // On s'assure que tout est propre pour le Round 1
                    root.totalScore = 0;
                    root.currentRoundIndex = 0;
                    root.isGameOver = false;

                    // On cache les anciens pins au cas où
                    pin.visible = false;
                    targetPin.visible = false;
                    lineCanvas.visible = false;

                    // SÉCURITÉ : On s'assure que le slider est bien au début
                    control.value = control.from;

                    // On lance le jeu
                    root.gameStarted = true;
                }
            }
        }
    }

    // --- BADGE DE PROGRESSION PLUS DISCRET ---
    Rectangle {
        id: roundBadge
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter

        // Taille réduite par rapport à la date
        width: 130
        height: 40
        radius: height / 2
        color: "#ff3366"
        z: 15

        visible: gameStarted

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.4
            shadowVerticalOffset: 2
            shadowColor: "#40000000"
        }

        Text {
            anchors.centerIn: parent
            text: (currentRoundIndex + 1) + " / " + gameData.length
            color: "white"
            font.pixelSize: 16
            font.bold: true
        }
    }
}
