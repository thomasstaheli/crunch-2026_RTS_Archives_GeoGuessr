#ifndef GAMELOGIC_H
#define GAMELOGIC_H

#include <QObject>
#include <cmath>

class GameLogic : public QObject
{
    Q_OBJECT // Indispensable pour l'interaction QML

public:
    explicit GameLogic(QObject *parent = nullptr) : QObject(parent) {}

    // Q_INVOKABLE permet d'appeler cette fonction depuis le code QML
    Q_INVOKABLE int calculateScore(double pinX, double pinY, double targetX, double targetY) {
        // Calcul de la distance (Pythagore)
        double dx = targetX - pinX;
        double dy = targetY - pinY;
        double distance = std::sqrt(dx * dx + dy * dy);

        // Calcul du score (max 5000)
        int score = std::max(0, 5000 - static_cast<int>(distance * 5));
        return score;
    }
};

#endif // GAMELOGIC_H
