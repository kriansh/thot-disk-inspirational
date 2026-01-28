import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 1.0
import Qt5Compat.GraphicalEffects
import org.kde.ksysguard.sensors as Sensors
import org.kde.plasma.plasmoid 2.0

PlasmoidItem {

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: "NoBackground"


    property var valueUsage: 0


    FontLoader {
        id: acheB
        source: "../fonts/AcherusGrotesque-Bold.ttf"
    }
    FontLoader {
        id: acheEB
        source: "../fonts/couture-bld.otf"
    }

    Layout.minimumHeight: 80
    Layout.minimumWidth: 80
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight


    Sensors.SensorDataModel {
        id: maxQueryModel
        sensors: ["disk/all/usedPercent"]
        enabled: true

        onDataChanged: topLeft => {
            const value = parseFloat(data(topLeft, Sensors.SensorDataModel.Value));
            if (!isNaN(value)) {
                valueUsage = value / 100;
            }
        }
    }

    Timer {
        interval: 2000 // 1 segundo
        running: true
        repeat: true

        onTriggered: {
            // El modelo ya está activado, pero podemos forzar la consulta de datos.
            maxQueryModel.enabled = false;
            maxQueryModel.enabled = true;
        }
    }

    onValueUsageChanged: {
        if (valueUsage >= 0) {
            progressCanvas.requestPaint();
        }
    }

    Item {
        width: parent.height < parent.width ? parent.height : parent.width
        height: parent.height < parent.width ? parent.height : parent.width
        anchors.centerIn: parent

        Rectangle{
            id: mask
            color: "transparent"
            width: parent.height
            height: width
            radius: width/2
            visible: false
            Rectangle {
                id: intofCicle
                anchors.centerIn: parent
                width: parent.width*.65
                height: parent.height*.65
                color: "black"
                radius: width/2
            }
            Rectangle {
                id: rectangleOsMask
                width: parent.width/2
                height: parent.height/3
                color: "black"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
        Rectangle{
            id: mask2
            color: "transparent"
            width: parent.height
            height: width
            radius: width/2
            visible: false
            Rectangle {
                id: intofCicle2
                anchors.centerIn: parent
                width: parent.width*.65
                height: parent.height*.65
                color: "black"
                radius: width/2
            }
        }
        Rectangle {
            id: cicleBse
            anchors.centerIn: parent
            width: parent.height
            height: width
            color: "white"
            opacity: 0.6
            radius: width/2
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: mask
                invert: true
            }
        }
        Canvas {
            id: progressCanvas
            anchors.centerIn: parent
            width: parent.height
            height: width
            rotation: 180
            onPaint: {
                console.log("Dibujando en el Canvas");
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, progressCanvas.width, progressCanvas.height); // Limpia el canvas antes de dibujar

                // Dibuja el progreso
                ctx.fillStyle = cicleBse.color;
                ctx.beginPath();
                ctx.moveTo(progressCanvas.width / 2, progressCanvas.height / 2);
                ctx.arc(progressCanvas.width / 2, progressCanvas.height / 2, progressCanvas.width / 2, -Math.PI / 2, (-Math.PI / 2) + (2 * Math.PI * valueUsage));
                ctx.fill();
            }
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: mask2
                invert: true
            }
        }
        Column {
            width: parent.width/2
            height: parent.height/3.6
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: - one.font.pixelSize*.4
            Text {
                anchors.left: parent.left
                anchors.leftMargin: parent.height*.1
                id: one
                color: cicleBse.color
                text: i18n("DISK")
                font.family: acheEB.name
                font.pixelSize: cicleBse.height*.16
                verticalAlignment: Text.AlignBottom
            }
            Text {
                anchors.left: parent.left
                anchors.leftMargin: parent.height*.1
                //anchors.top:  one.bottom
                id: two
                color: cicleBse.color
                text: Math.round(valueUsage*100) + "%"
                font.family: acheB.name
                font.pixelSize: one.font.pixelSize*.8
                verticalAlignment: Text.AlignTop
            }
        }
    }
}
