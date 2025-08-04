//paymentpage.qml

import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts 6.5
import QtQuick.Effects
import QtQuick.Dialogs
import FirebaseAuth 1.0

Rectangle {
    id: paymentRoot
    anchors.fill: parent

    property var orderData: Qt.application.currentOrder || {
        restaurant: "Sherpa Hotel",
        restaurantIcon: "🏔️",
        items: [
            { name: "Chicken Momo", price: 120, quantity: 2 },
            { name: "Buff Chowmein", price: 150, quantity: 1 },
            { name: "Tea", price: 30, quantity: 2 }
        ],
        subtotal: 420,
        deliveryFee: 50,
        totalAmount: 470,
        totalItems: 5,
        orderDate: "2025-01-15",
        orderTime: "15:30:01",
        customerName: "guest",
        isStudent: false
    }

    property string transactionId: ""
    property string deliveryAddress: ""
    property bool isSubmittingOrder: false

    // Student status detection
    property bool isStudent: orderData.isStudent || false
    property string userDisplayName: orderData.customerName || "guest"

    FirebaseAuth {
        id: firebaseAuth

        onOrderSubmitted: function(success, message, orderId) {
            console.log("🔥 ORDER SUBMISSION RESULT:")
            console.log("  ✅ Success:", success)
            console.log("  📝 Message:", message)
            console.log("  🆔 Order ID:", orderId)

            isSubmittingOrder = false

            if (success) {
                console.log("🎉 SUCCESS: Order was submitted to Firebase!")
                successDialog.orderMessage = message
                successDialog.orderId = orderId
                successDialog.open()
            } else {
                console.log("❌ ERROR: Order submission failed!")
                errorDialog.errorMessage = message
                errorDialog.open()
            }
        }
    }

    gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0.0; color: "#0a0b14" }
        GradientStop { position: 0.3; color: "#111827" }
        GradientStop { position: 0.7; color: "#1f2937" }
        GradientStop { position: 1.0; color: "#0f172a" }
    }

    Dialog {
        id: successDialog
        property string orderMessage: ""
        property string orderId: ""
        anchors.centerIn: parent
        width: Math.min(400, parent.width - 40)
        height: Math.min(400, parent.height - 100)
        modal: true
        closePolicy: Dialog.CloseOnEscape | Dialog.CloseOnPressOutside

        background: Rectangle {
            radius: 16
            color: "#1e293b"
            border.width: 2
            border.color: "#10b981"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Text {
                text: "✅"
                font.pixelSize: 50
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Order Placed Successfully!"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: "#10b981"
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                text: "Order ID: " + successDialog.orderId
                font.pixelSize: 12
                color: "#9ca3af"
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }

            // Student discount notice
            Text {
                text: isStudent ? "🎓 Student Discount Applied: FREE Delivery!" : ""
                font.pixelSize: 14
                font.weight: Font.Bold
                color: "#10b981"
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                visible: isStudent
            }

            Text {
                text: "Thank you for your order!\nYou will receive confirmation shortly."
                font.pixelSize: 12
                color: "#f9fafb"
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            // User status display
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 8
                color: isStudent ? "#10b981" : "#6b7280"
                opacity: 0.2

                Text {
                    anchors.centerIn: parent
                    text: isStudent ? "👨‍🎓 Student User" : "👤 Regular User"
                    font.pixelSize: 12
                    color: "#f9fafb"
                    font.weight: Font.Medium
                }
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.preferredWidth: 150
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter
                radius: 20
                color: "#10b981"

                Text {
                    anchors.centerIn: parent
                    text: "Continue Shopping"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: "#ffffff"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        successDialog.close()
                        pageLoader.source = "selectrestaurant.qml"
                    }
                }
            }
        }
    }

    Dialog {
        id: errorDialog
        property string errorMessage: ""
        anchors.centerIn: parent
        width: Math.min(350, parent.width - 40)
        height: Math.min(250, parent.height - 100)
        modal: true
        closePolicy: Dialog.CloseOnEscape | Dialog.CloseOnPressOutside

        background: Rectangle {
            radius: 16
            color: "#1e293b"
            border.width: 2
            border.color: "#ef4444"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Text {
                text: "❌"
                font.pixelSize: 50
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Order Failed"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: "#ef4444"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: errorDialog.errorMessage
                font.pixelSize: 12
                color: "#f9fafb"
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter
                radius: 20
                color: "#ef4444"

                Text {
                    anchors.centerIn: parent
                    text: "Try Again"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: "#ffffff"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: errorDialog.close()
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: Qt.rgba(0.15, 0.18, 0.25, 0.85)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.1)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 16

                // Back Button
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
                    radius: 18
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.15)

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "←"; color: "#f9fafb"; font.pixelSize: 14 }
                        Text { text: "Back"; color: "#f9fafb"; font.pixelSize: 12 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageLoader.source = "selectrestaurant.qml"
                    }
                }

                // Title
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 12
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "#10b981" }
                            GradientStop { position: 1.0; color: "#059669" }
                        }
                        Text { anchors.centerIn: parent; text: "💳"; font.pixelSize: 16 }
                    }

                    ColumnLayout {
                        spacing: 1
                        Text { text: "QR PAYMENT"; font.pixelSize: 16; font.weight: Font.Bold; color: "#f9fafb" }
                        Text { text: "Scan & Pay Securely"; font.pixelSize: 10; color: "#10b981" }
                    }
                }

                // User status indicator
                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 32
                    radius: 16
                    color: isStudent ? "#10b981" : "#6b7280"
                    opacity: 0.8

                    Text {
                        anchors.centerIn: parent
                        text: isStudent ? "👨‍🎓 Student" : "👤 Regular"
                        font.pixelSize: 10
                        color: "#ffffff"
                        font.weight: Font.Medium
                    }
                }
            }
        }

        // Main ScrollView
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: paymentRoot.width
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: paymentRoot.width
                spacing: 20

                // Page Title
                Text {
                    text: "COMPLETE YOUR ORDER"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    color: "#f9fafb"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                }

                // Order Info with Student Status
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    radius: 12
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.rgba(245, 158, 11, 0.15) }
                        GradientStop { position: 1.0; color: Qt.rgba(16, 185, 129, 0.15) }
                    }
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.2)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        RowLayout {
                            spacing: 12

                            Text { text: orderData.restaurantIcon; font.pixelSize: 24 }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "Order from " + orderData.restaurant
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: "#f9fafb"
                                }

                                RowLayout {
                                    spacing: 16
                                    Text { text: "📅 " + orderData.orderDate; font.pixelSize: 10; color: "#9ca3af" }
                                    Text { text: "🕒 " + orderData.orderTime; font.pixelSize: 10; color: "#9ca3af" }
                                }
                            }
                        }

                        // Student discount notice
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 24
                            radius: 12
                            color: isStudent ? "#10b981" : "#6b7280"
                            opacity: 0.2

                            Text {
                                anchors.centerIn: parent
                                text: isStudent ? "🎓 Student Discount: FREE Delivery!" : "👤 Regular User: Rs 50 Delivery Fee"
                                font.pixelSize: 10
                                color: "#f9fafb"
                                font.weight: Font.Medium
                            }
                        }
                    }
                }

                // QR Payment Section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.preferredHeight: 550
                    radius: 12
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.08) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.03) }
                    }
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.12)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        // QR Header
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            radius: 10
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#3b82f6" }
                                GradientStop { position: 1.0; color: "#2563eb" }
                            }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: "📱"; font.pixelSize: 16 }
                                Text { text: "QR Payment"; font.pixelSize: 14; font.weight: Font.Bold; color: "#ffffff" }
                            }
                        }

                        // QR Code
                        Rectangle {
                            Layout.preferredWidth: 140
                            Layout.preferredHeight: 140
                            Layout.alignment: Qt.AlignHCenter
                            radius: 10
                            color: "#ffffff"
                            border.width: 2
                            border.color: "#e5e7eb"

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "📱"; font.pixelSize: 40; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "QR CODE"; font.pixelSize: 12; font.weight: Font.Bold; color: "#1f2937"; Layout.alignment: Qt.AlignHCenter }
                            }
                        }

                        // Dynamic amount display based on student status
                        Text {
                            text: "Amount to Pay: ₹" + (isStudent ? orderData.subtotal : orderData.totalAmount)
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: "#10b981"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "📱 Open UPI app → 📷 Scan QR → 💰 Pay ₹" + (isStudent ? orderData.subtotal : orderData.totalAmount)
                            font.pixelSize: 11
                            color: "#9ca3af"
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        // Transaction ID Input
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Transaction ID"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#f9fafb"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                radius: 8
                                color: Qt.rgba(1, 1, 1, 0.06)
                                border.width: 2
                                border.color: transactionField.activeFocus ? "#10b981" : Qt.rgba(1, 1, 1, 0.12)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8

                                    Rectangle {
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        radius: 4
                                        color: Qt.rgba(16, 185, 129, 0.15)
                                        Text { anchors.centerIn: parent; text: "🔢"; font.pixelSize: 12 }
                                    }

                                    TextInput {
                                        id: transactionField
                                        Layout.fillWidth: true
                                        font.pixelSize: 12
                                        color: "#f9fafb"
                                        selectByMouse: true
                                        verticalAlignment: TextInput.AlignVCenter
                                        text: transactionId
                                        onTextChanged: transactionId = text

                                        Text {
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: "Enter 12-digit transaction ID"
                                            font.pixelSize: 12
                                            color: "#6b7280"
                                            visible: transactionField.text.length === 0 && !transactionField.activeFocus
                                        }
                                    }
                                }
                            }
                        }

                        // Delivery Address Input
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: "Delivery Address"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: "#f9fafb"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 80
                                radius: 10
                                color: Qt.rgba(1, 1, 1, 0.06)
                                border.width: 2
                                border.color: addressField.activeFocus ? "#10b981" : Qt.rgba(1, 1, 1, 0.12)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10

                                    Rectangle {
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
                                        Layout.alignment: Qt.AlignTop
                                        Layout.topMargin: 4
                                        radius: 6
                                        color: Qt.rgba(16, 185, 129, 0.15)
                                        Text { anchors.centerIn: parent; text: "📍"; font.pixelSize: 14 }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"

                                        ScrollView {
                                            anchors.fill: parent
                                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                            ScrollBar.vertical.policy: ScrollBar.AsNeeded

                                            TextArea {
                                                id: addressField
                                                width: parent.width
                                                font.pixelSize: 14
                                                color: "#f9fafb"
                                                selectByMouse: true
                                                wrapMode: TextArea.Wrap
                                                text: deliveryAddress
                                                background: Rectangle { color: "transparent" }
                                                onTextChanged: deliveryAddress = text
                                                // Remove placeholderText and placeholderTextColor properties
                                            }
                                        }

                                        // Custom placeholder text that behaves like transaction ID field
                                        Text {
                                            anchors.left: parent.left
                                            anchors.top: parent.top
                                            anchors.margins: 8
                                            text: "Enter your complete delivery address"
                                            font.pixelSize: 14
                                            color: "#6b7280"
                                            visible: addressField.text.length === 0 && !addressField.activeFocus
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                }
                            }
                        }


                        // Place Order Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            radius: 22

                            property bool canPlaceOrder: transactionId.length >= 12 && deliveryAddress.length > 10 && !isSubmittingOrder

                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: parent.canPlaceOrder ? "#10b981" : "#6b7280" }
                                GradientStop { position: 1.0; color: parent.canPlaceOrder ? "#059669" : "#9ca3af" }
                            }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 10
                                Text { text: isSubmittingOrder ? "⏳" : "🚀"; font.pixelSize: 16 }
                                Text {
                                    text: isSubmittingOrder ? "PLACING ORDER..." : "PLACE ORDER"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: "#ffffff"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: parent.canPlaceOrder
                                onClicked: {
                                    isSubmittingOrder = true

                                    // Calculate actual delivery fee based on student status
                                    var actualDeliveryFee = isStudent ? 0 : 50
                                    var actualTotalAmount = orderData.subtotal + actualDeliveryFee

                                    var orderForFirebase = {
                                        userEmail: Qt.application.currentUserEmail || firebaseAuth.currentUserEmail || "guest@bytebite.com",
                                        deliveryAddress: deliveryAddress,
                                        transactionId: transactionId,
                                        items: orderData.items,
                                        subtotal: orderData.subtotal,
                                        deliveryFee: actualDeliveryFee,
                                        totalAmount: actualTotalAmount,
                                        orderDate: orderData.orderDate,
                                        orderTime: orderData.orderTime,
                                        restaurant: orderData.restaurant,
                                        customerName: userDisplayName,
                                        isStudent: isStudent
                                    }

                                    firebaseAuth.submitOrder(JSON.stringify(orderForFirebase))
                                }
                            }
                        }

                        // Validation Message
                        Text {
                            text: {
                                if (transactionId.length === 0) return "⚠️ Please enter transaction ID"
                                if (transactionId.length < 12) return "⚠️ Transaction ID must be 12 digits"
                                if (deliveryAddress.length === 0) return "⚠️ Please enter delivery address"
                                if (deliveryAddress.length < 10) return "⚠️ Please enter complete address"
                                return "✅ Ready to place order"
                            }
                            font.pixelSize: 10
                            color: (transactionId.length >= 12 && deliveryAddress.length > 10) ? "#10b981" : "#f59e0b"
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }
                    }
                }

                // Order Summary Section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    Layout.preferredHeight: 350
                    radius: 12
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.08) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.03) }
                    }
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.12)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        // Summary Header
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            radius: 10
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#f59e0b" }
                                GradientStop { position: 1.0; color: "#d97706" }
                            }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: "📋"; font.pixelSize: 16 }
                                Text { text: "Order Summary"; font.pixelSize: 14; font.weight: Font.Bold; color: "#ffffff" }
                            }
                        }

                        // Items Header
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Order Items (" + orderData.totalItems + ")"; font.pixelSize: 12; font.weight: Font.Bold; color: "#f9fafb" }
                            Item { Layout.fillWidth: true }
                            Text { text: orderData.restaurant; font.pixelSize: 10; color: "#9ca3af" }
                        }

                        // Order Items List
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentWidth: width
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded

                            ColumnLayout {
                                width: parent.width
                                spacing: 6

                                Repeater {
                                    model: orderData.items

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 45
                                        radius: 8
                                        color: Qt.rgba(1, 1, 1, 0.05)
                                        border.width: 1
                                        border.color: Qt.rgba(1, 1, 1, 0.1)

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 1

                                                Text {
                                                    text: modelData.name
                                                    font.pixelSize: 12
                                                    font.weight: Font.Bold
                                                    color: "#f9fafb"
                                                }

                                                Text {
                                                    text: "Rs " + modelData.price + " × " + modelData.quantity
                                                    font.pixelSize: 10
                                                    color: "#9ca3af"
                                                }
                                            }

                                            Text {
                                                text: "Rs " + (modelData.price * modelData.quantity)
                                                font.pixelSize: 12
                                                font.weight: Font.Bold
                                                color: "#f59e0b"
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Price Summary with Student Discount
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Qt.rgba(1, 1, 1, 0.2) }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Subtotal"; font.pixelSize: 11; color: "#9ca3af" }
                                Item { Layout.fillWidth: true }
                                Text { text: "Rs " + orderData.subtotal; font.pixelSize: 11; color: "#f9fafb" }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: isStudent ? "Delivery Fee (Student Discount)" : "Delivery Fee"
                                    font.pixelSize: 11; color: "#9ca3af"
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: isStudent ? "FREE" : "Rs 50"
                                    font.pixelSize: 11
                                    color: isStudent ? "#10b981" : "#f9fafb"
                                    font.weight: isStudent ? Font.Bold : Font.Normal
                                }
                            }

                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Qt.rgba(1, 1, 1, 0.2) }

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Total"; font.pixelSize: 14; font.weight: Font.Bold; color: "#f9fafb" }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "Rs " + (isStudent ? orderData.subtotal : orderData.totalAmount)
                                    font.pixelSize: 16; font.weight: Font.Bold; color: "#10b981"
                                }
                            }
                        }
                    }
                }

                // Bottom spacing
                Item { Layout.preferredHeight: 30 }
            }
        }
    }

    Component.onCompleted: {
        console.log("✅ Payment Page with Student Discount Feature")
        console.log("✅ Student Status:", isStudent)
        console.log("✅ User Display Name:", userDisplayName)
        console.log("✅ Delivery Fee:", isStudent ? "FREE" : "Rs 50")
        console.log("✅ Final Total:", isStudent ? orderData.subtotal : orderData.totalAmount)
    }
}
