import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts
import FirebaseAuth 1.0

Rectangle {
    id: orderStatusRoot
    anchors.fill: parent

    property var orders: []
    property bool isLoading: false

    FirebaseAuth {
        id: firebaseAuth

        Component.onCompleted: {
            // Load user's orders when page opens
            loadUserOrders()
        }
    }

    function loadUserOrders() {
        isLoading = true

        // Get current user email
        var userEmail = Qt.application.currentUserEmail || firebaseAuth.currentUserEmail || "guest@bytebite.com"

        console.log("📱 Loading orders for user:", userEmail)

        // Make Firebase request to get user's orders
        var xhr = new XMLHttpRequest()
        var url = "https://firestore.googleapis.com/v1/projects/bytebitelogin/databases/(default)/documents/orders?key=AIzaSyBSfOQQPEIUDkh16EVPU9j9IGCdhEyx-lE"

        xhr.open("GET", url, true)
        xhr.setRequestHeader("User-Agent", "ByteBite-User/1.0")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isLoading = false

                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        var documents = response.documents || []

                        console.log("📦 Processing", documents.length, "total orders from Firebase")

                        var userOrders = []

                        for (var i = 0; i < documents.length; i++) {
                            var doc = documents[i]
                            var fields = doc.fields || {}

                            // Safe field extraction
                            function getString(key) {
                                return fields[key] && fields[key].stringValue ? fields[key].stringValue : ""
                            }

                            function getInt(key) {
                                return fields[key] && fields[key].integerValue ? parseInt(fields[key].integerValue) : 0
                            }

                            var orderEmail = getString("userEmail")

                            // Filter orders for current user
                            if (orderEmail === userEmail) {
                                var order = {
                                    orderId: getString("orderId"),
                                    restaurant: getString("restaurant"),
                                    status: getString("status") || "pending",
                                    totalAmount: getInt("totalAmount"),
                                    orderDate: getString("orderDate"),
                                    orderTime: getString("orderTime"),
                                    deliveryAddress: getString("deliveryAddress"),
                                    transactionId: getString("transactionId")
                                }

                                userOrders.push(order)

                                console.log("✅ USER ORDER:", order.orderId,
                                           "| Status:", order.status,
                                           "| Restaurant:", order.restaurant,
                                           "| Amount: ₹" + order.totalAmount)
                            }
                        }

                        // Sort orders by date (newest first)
                        userOrders.sort(function(a, b) {
                            return new Date(b.orderDate) - new Date(a.orderDate)
                        })

                        orders = userOrders
                        orderListModel.clear()

                        for (var j = 0; j < userOrders.length; j++) {
                            orderListModel.append(userOrders[j])
                        }

                        console.log("🎯 LOADED", userOrders.length, "orders for user:", userEmail)

                    } catch (e) {
                        console.log("❌ Error parsing orders:", e.message)
                    }
                } else {
                    console.log("❌ Failed to load orders:", xhr.status, xhr.statusText)
                }
            }
        }

        xhr.send()
    }

    gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.0; color: "#0a0b14" }
        GradientStop { position: 0.3; color: "#111827" }
        GradientStop { position: 0.7; color: "#1f2937" }
        GradientStop { position: 1.0; color: "#0f172a" }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Qt.rgba(0.15, 0.18, 0.25, 0.9)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 20
                    color: Qt.rgba(1, 1, 1, 0.08)

                    Text {
                        anchors.centerIn: parent
                        text: "←"
                        color: "#f9fafb"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageLoader.source = "selectrestaurant.qml"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 8
                        color: "#3b82f6"

                        Text {
                            anchors.centerIn: parent
                            text: "📋"
                            font.pixelSize: 16
                        }
                    }

                    ColumnLayout {
                        spacing: 2

                        Text {
                            text: "MY ORDERS"
                            font.family: "SF Pro Display, Segoe UI"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: "#f9fafb"
                        }

                        Text {
                            text: "Track Your Orders"
                            font.family: "SF Pro Text, Segoe UI"
                            font.pixelSize: 10
                            color: "#3b82f6"
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    radius: 16
                    color: "#10b981"

                    Text {
                        anchors.centerIn: parent
                        text: "🔄 Refresh"
                        font.pixelSize: 10
                        color: "#ffffff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: loadUserOrders()
                    }
                }
            }
        }

        // Content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: parent.width
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 16

                // Title
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    spacing: 8

                    Text {
                        text: "ORDER HISTORY"
                        font.family: "SF Pro Display, Segoe UI"
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: "#f9fafb"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 3
                        Layout.alignment: Qt.AlignHCenter
                        radius: 2
                        color: "#3b82f6"
                    }
                }

                // Loading indicator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    Layout.margins: 16
                    radius: 12
                    color: Qt.rgba(1, 1, 1, 0.08)
                    visible: isLoading

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            text: "⏳"
                            font.pixelSize: 20
                        }

                        Text {
                            text: "Loading your orders..."
                            font.pixelSize: 14
                            color: "#f9fafb"
                        }
                    }
                }

                // Orders List
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    spacing: 16
                    visible: !isLoading

                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(200, count * 160)
                        model: ListModel { id: orderListModel }
                        spacing: 12

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 150
                            radius: 16
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1
                            border.color: {
                                if (model.status === "confirmed") return "#10b981"
                                if (model.status === "rejected") return "#ef4444"
                                return "#f59e0b"
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 8

                                // Order Header
                                RowLayout {
                                    Layout.fillWidth: true

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: "Order #" + (model.orderId || "Unknown").slice(-8)
                                            font.pixelSize: 14
                                            font.weight: Font.Bold
                                            color: "#f9fafb"
                                        }

                                        Text {
                                            text: model.restaurant || "Unknown Restaurant"
                                            font.pixelSize: 12
                                            color: "#9ca3af"
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 80
                                        Layout.preferredHeight: 24
                                        radius: 12
                                        color: {
                                            if (model.status === "confirmed") return "#10b981"
                                            if (model.status === "rejected") return "#ef4444"
                                            return "#f59e0b"
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: {
                                                if (model.status === "confirmed") return "✅ Confirmed"
                                                if (model.status === "rejected") return "❌ Rejected"
                                                return "⏳ Pending"
                                            }
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                            color: "#ffffff"
                                        }
                                    }
                                }

                                // Order Details
                                RowLayout {
                                    Layout.fillWidth: true

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4

                                        Text {
                                            text: "📅 " + (model.orderDate || "Unknown Date")
                                            font.pixelSize: 10
                                            color: "#9ca3af"
                                        }

                                        Text {
                                            text: "🕒 " + (model.orderTime || "Unknown Time")
                                            font.pixelSize: 10
                                            color: "#9ca3af"
                                        }

                                        Text {
                                            text: "📍 " + (model.deliveryAddress || "No address").slice(0, 30) + "..."
                                            font.pixelSize: 10
                                            color: "#9ca3af"
                                        }
                                    }

                                    Text {
                                        text: "₹" + (model.totalAmount || 0)
                                        font.pixelSize: 18
                                        font.weight: Font.Bold
                                        color: {
                                            if (model.status === "confirmed") return "#10b981"
                                            if (model.status === "rejected") return "#ef4444"
                                            return "#f59e0b"
                                        }
                                    }
                                }

                                // Transaction ID
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 30
                                    radius: 8
                                    color: Qt.rgba(1, 1, 1, 0.05)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "🔢 Transaction ID: " + (model.transactionId || "Not provided")
                                        font.pixelSize: 10
                                        color: "#9ca3af"
                                    }
                                }
                            }
                        }
                    }

                    // No orders message
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.05)
                        visible: orderListModel.count === 0 && !isLoading

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "📋"
                                font.pixelSize: 30
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "No orders found"
                                font.pixelSize: 14
                                color: "#9ca3af"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "Place your first order to see it here"
                                font.pixelSize: 11
                                color: "#6b7280"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                Item { Layout.preferredHeight: 20 }
            }
        }
    }

    Component.onCompleted: {
        console.log("📱 Order Status page loaded")
        console.log("👤 User: Sumit-51")
        console.log("🕒 Time: 2025-08-03 07:22:05")
    }
}
