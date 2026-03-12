#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "gamelogic.h"

// On ajoute ceci pour activer le nouveau suffixe "_s"
using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    GameLogic logic;
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("gameLogic", &logic);

    const QUrl url(u"qrc:/qt/qml/crunch_interactive_map/Main.qml"_s);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
