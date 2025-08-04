import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5
import FirebaseAuth 1.0

Rectangle {
    id: trackingRoot
    anchors.fill: parent

    property var userOrders: []

    gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.0; color: "#0a0b14" }
        GradientStop { position: 1.0; color: "#1e293b" }
    }

    FirebaseAuth {
        id: firebaseAuth

        onUserOrdersLoaded: function(success, ordersJson) {
            console.log("📋 Orders loaded:", success, ordersJson)

            if (success) {
                try {
                    userOrders = JSON.parse(ordersJson)
                    ordersModel.clear()

                    for (var i = 0; i < userOrders.length; i++) {
                        ordersModel.append(userOrders[i])
                    }

                    console.log("✅ Loaded", userOrders.length, "orders")
                } catch (e) {
                    console.log("❌ JSON parse error:", e)
                }
            }
        }
    }

    function getStatusColor(status) {
        switch(status.toLowerCase()) {
        case "pending":
            return "#f59e0b"
        case "confirmed":
            return "#10b981"
        case "rejected":
            return "#ef4444"
        default:
            return "#6b7280"
        }
    }

    function getStatusIcon(status) {
        switch(status.toLowerCase()) {
        case "pending":
            return "⏳"
        case "confirmed":
            return "✅"
        case "rejected":
            return "❌"
        default:
            return "❓"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: "#1e293b"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 20
                    color: "#334155"

                    Text {
                        anchors.centerIn: parent
                        text: "←"
                        color: "#f8fafc"
                        font.pixelSize: 18
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageLoader.source = "selectrestaurant.qml"
                    }
                }

                Text {
                    text: "📦 My Orders"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: "#f8fafc"
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 20
                    color: "#334155"

                    Text {
                        anchors.centerIn: parent
                        text: "🔄"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: firebaseAuth.fetchUserOrders()
                    }
                }
            }
        }

        // Orders List
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: ListModel { id: ordersModel }
            spacing: 8
            clip: true

            delegate: Rectangle {
                width: parent.width
                height: 100
                color: "#334155"
                border.color: getStatusColor(model.status)
                border.width: 2
                radius: 12

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 16

                    // Status Icon
                    Rectangle {
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 50
                        radius: 25
                        color: getStatusColor(model.status)

                        Text {
                            anchors.centerIn: parent
                            text: getStatusIcon(model.status)
                            font.pixelSize: 20
                        }
                    }

                    // Order Info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: model.orderId || "Unknown Order"
                            color: "#f8fafc"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                        }

                        Text {
                            text: "🏪 " + (model.restaurant || "Unknown")
                            color: "#94a3b8"
                            font.pixelSize: 12
                        }

                        Text {
                            text: "💰 ₹" + (model.totalAmount || 0)
                            color: "#3b82f6"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        Text {
                            text: "📅 " + (model.orderDate || "") + " " + (model.orderTime || "")
                            color: "#94a3b8"
                            font.pixelSize: 10
                        }
                    }

                    // Status
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 30
                        radius: 15
                        color: getStatusColor(model.status)

                        Text {
                            anchors.centerIn: parent
                            text: (model.status || "pending").toUpperCase()
                            color: "#ffffff"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            // Empty State
            Text {
                anchors.centerIn: parent
                text: "📦 No orders found\n\nStart ordering from restaurants!"
                color: "#94a3b8"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                visible: parent.count === 0
            }
        }
    }

    Component.onCompleted: {
        console.log("🔥 Order Tracking Page Loaded - 2025-08-03 06:18:04")
        console.log("👤 User: Sumit-51")
        firebaseAuth.fetchUserOrders()
    }
}
