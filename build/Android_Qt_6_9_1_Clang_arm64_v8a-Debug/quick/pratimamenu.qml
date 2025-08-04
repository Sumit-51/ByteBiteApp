import QtQuick 6.5
import QtQuick.Controls 6.5
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: menuRoot
    anchors.fill: parent

    property real dp: Math.min(width / 375, height / 812)

    // Dynamic menu items loaded from Firebase
    property var menuItems: []
    property bool isLoadingMenu: false

    property var cart: ({})
    property int totalAmount: 0
    property int totalItems: 0
    property int cartUpdateTrigger: 0

    // Load menu from Firebase
    // Load menu from Firebase with smart emoji support
    function loadMenuFromFirebase() {
        isLoadingMenu = true
        console.log("📱 USER: Loading Pratima menu from Firebase with smart emojis...")

        var xhr = new XMLHttpRequest()
        var url = "https://firestore.googleapis.com/v1/projects/bytebitelogin/databases/(default)/documents/menu_availability/pratima/items?key=AIzaSyBSfOQQPEIUDkh16EVPU9j9IGCdhEyx-lE"

        xhr.open("GET", url, true)
        xhr.setRequestHeader("User-Agent", "ByteBite-User/1.0")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isLoadingMenu = false

                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        var documents = response.documents || []

                        console.log("📦 Processing", documents.length, "menu items for Pratima")

                        var availableItems = []

                        for (var i = 0; i < documents.length; i++) {
                            var doc = documents[i]
                            var fields = doc.fields || {}

                            // Extract item ID from document name
                            var documentName = doc.name || ""
                            var itemId = documentName.split("/").pop()

                            // Safe field extraction
                            function getString(key) {
                                return fields[key] && fields[key].stringValue ? fields[key].stringValue : ""
                            }

                            function getInt(key) {
                                return fields[key] && fields[key].integerValue ? parseInt(fields[key].integerValue) : 0
                            }

                            function getBool(key) {
                                return fields[key] && fields[key].booleanValue !== undefined ? fields[key].booleanValue : true
                            }

                            // 🎯 CREATE ITEM WITH FIREBASE EMOJI
                            var item = {
                                id: itemId,
                                name: getString("name"),
                                price: getInt("price"),
                                available: getBool("available"),
                                image: getString("emoji") || getSmartEmoji(getString("name")), // 🎯 Use Firebase emoji or fallback
                                updatedAt: getString("updatedAt"),
                                updatedBy: getString("updatedBy")
                            }

                            // 🎨 SMART COLOR ASSIGNMENT based on emoji
                            item.color = getColorForEmoji(item.image)

                            // 📝 SMART DESCRIPTION based on item name
                            item.description = getDescriptionForItem(item.name)

                            // 🎯 CRITICAL: Only show available items to users
                            if (item.available && item.name !== "") {
                                availableItems.push(item)

                                console.log("✅ USER SEES:", item.name,
                                           "| Price: ₹" + item.price,
                                           "| Emoji:", item.image,
                                           "| Available:", item.available)
                            } else {
                                console.log("❌ HIDDEN FROM USER:", item.name,
                                           "| Available:", item.available)
                            }
                        }

                        menuItems = availableItems
                        console.log("🎯 PRATIMA MENU: Showing", availableItems.length, "available items to user")
                        console.log("🕒 Last updated: 2025-08-03 09:46:58 UTC | User: Sumit-51")

                    } catch (e) {
                        console.log("❌ Error parsing menu:", e.message)
                    }
                } else {
                    console.log("❌ Failed to load menu:", xhr.status, xhr.statusText)
                }
            }
        }

        xhr.send()
    }

    // 🎯 SMART EMOJI FALLBACK FUNCTION (if Firebase doesn't have emoji)
    function getSmartEmoji(itemName) {
        if (!itemName) return "🍽️"

        var name = itemName.toLowerCase()

        // 🍔 BURGER & SANDWICH
        if (name.includes("burger") || name.includes("sandwich")) return "🍔"

        // 🥟 DUMPLINGS & MOMO
        if (name.includes("momo") || name.includes("dumpling")) return "🥟"

        // 🍜 NOODLES & CHOWMEIN
        if (name.includes("chowmein") || name.includes("noodle") || name.includes("ramen")) return "🍜"

        // 🍛 RICE DISHES
        if (name.includes("biryani") || name.includes("pulao")) return "🍛"

        // 🍚 FRIED RICE
        if (name.includes("fried rice") || name.includes("rice")) return "🍚"

        // 🍕 PIZZA
        if (name.includes("pizza")) return "🍕"

        // 🌮 TACOS & WRAPS
        if (name.includes("taco") || name.includes("wrap")) return "🌮"

        // 🥗 SALADS
        if (name.includes("salad")) return "🥗"

        // 🍗 CHICKEN ITEMS
        if (name.includes("chicken") && (name.includes("roast") || name.includes("grill") || name.includes("fry"))) return "🍗"

        // 🥩 MEAT & STEAKS
        if (name.includes("steak") || name.includes("beef") || name.includes("mutton") || name.includes("buff")) return "🥩"

        // 🐟 FISH & SEAFOOD
        if (name.includes("fish") || name.includes("seafood")) return "🐟"

        // 🍰 DESSERTS & SWEETS
        if (name.includes("cake") || name.includes("pastry") || name.includes("dessert")) return "🍰"

        // 🍡 TRADITIONAL SWEETS
        if (name.includes("laddu") || name.includes("barfi") || name.includes("rasgulla") ||
            name.includes("gulab jamun") || name.includes("lalmohan") || name.includes("jerry")) return "🍡"

        // 🥟 SAMOSA & SNACKS
        if (name.includes("samosa") || name.includes("pakora")) return "🥟"

        // ☕ BEVERAGES
        if (name.includes("tea") || name.includes("coffee") || name.includes("chai")) return "☕"

        // 🥤 COLD DRINKS
        if (name.includes("pepsi") || name.includes("coke") || name.includes("juice") || name.includes("smoothie")) return "🥤"

        // 🍺 ALCOHOLIC BEVERAGES
        if (name.includes("beer") || name.includes("tuborg") || name.includes("budweiser")) return "🍺"

        // 🍲 SOUPS & STEWS
        if (name.includes("soup") || name.includes("stew")) return "🍲"

        // 🥞 BREAKFAST ITEMS
        if (name.includes("pancake") || name.includes("waffle") || name.includes("toast")) return "🥞"

        // 🍳 EGGS
        if (name.includes("egg") || name.includes("omelet")) return "🍳"

        // 🧀 CHEESE ITEMS
        if (name.includes("cheese") || name.includes("paneer")) return "🧀"

        // 🌶️ SPICY ITEMS
        if (name.includes("chilly") || name.includes("spicy") || name.includes("hot")) return "🌶️"

        // 🍽️ DEFAULT
        return "🍽️"
    }

    // 🎨 COLOR ASSIGNMENT based on emoji
    function getColorForEmoji(emoji) {
        switch(emoji) {
            case "🍔": return "#ef4444"  // Red for burgers
            case "🥟": return "#10b981"  // Green for momos/samosas
            case "🍜": return "#3b82f6"  // Blue for noodles
            case "🍛": return "#f59e0b"  // Orange for biryani
            case "🍚": return "#8b5cf6"  // Purple for fried rice
            case "🍕": return "#ef4444"  // Red for pizza
            case "🌮": return "#f59e0b"  // Orange for tacos
            case "🥗": return "#10b981"  // Green for salads
            case "🍗": return "#06b6d4"  // Cyan for chicken
            case "🥩": return "#dc2626"  // Dark red for meat
            case "🐟": return "#0ea5e9"  // Light blue for fish
            case "🍰": return "#ec4899"  // Pink for cakes
            case "🍡": return "#a855f7"  // Purple for sweets
            case "☕": return "#92400e"  // Brown for coffee/tea
            case "🥤": return "#3b82f6"  // Blue for cold drinks
            case "🍺": return "#10b981"  // Green for beer
            case "🍲": return "#f59e0b"  // Orange for soups
            case "🥞": return "#fbbf24"  // Yellow for pancakes
            case "🍳": return "#fbbf24"  // Yellow for eggs
            case "🧀": return "#f59e0b"  // Orange for cheese
            case "🌶️": return "#ef4444"  // Red for spicy
            default: return "#6b7280"   // Gray for unknown
        }
    }

    // 📝 DESCRIPTION based on item name
    function getDescriptionForItem(itemName) {
        if (!itemName) return "Delicious food item"

        var name = itemName.toLowerCase()

        if (name.includes("momo")) return "Steamed dumplings with spicy sauce"
        if (name.includes("chowmein")) return "Stir-fried noodles with vegetables"
        if (name.includes("biryani")) return "Aromatic rice with tender pieces"
        if (name.includes("fried rice")) return "Wok-fried rice with vegetables"
        if (name.includes("burger")) return "Juicy patty with fresh vegetables"
        if (name.includes("samosa")) return "Crispy pastry with spiced filling"
        if (name.includes("pizza")) return "Fresh pizza with toppings"
        if (name.includes("salad")) return "Fresh mixed vegetables"
        if (name.includes("chicken")) return "Tender chicken preparation"
        if (name.includes("fish")) return "Fresh fish delicacy"
        if (name.includes("cake")) return "Sweet dessert treat"
        if (name.includes("tea") || name.includes("coffee")) return "Hot beverage"
        if (name.includes("juice") || name.includes("pepsi")) return "Refreshing cold drink"
        if (name.includes("beer")) return "Chilled alcoholic beverage"
        if (name.includes("soup")) return "Warm comforting soup"
        if (name.includes("egg")) return "Fresh egg preparation"
        if (name.includes("paneer")) return "Cottage cheese delicacy"
        if (name.includes("chilly")) return "Spicy and flavorful dish"

        return "Delicious food item"
    }

    function addToCart(itemId, itemName, itemPrice) {
        if (cart[itemId]) {
            cart[itemId].quantity += 1
        } else {
            cart[itemId] = {
                name: itemName,
                price: itemPrice,
                quantity: 1
            }
        }
        updateCartTotals()
    }

    function removeFromCart(itemId) {
        if (cart[itemId]) {
            if (cart[itemId].quantity > 1) {
                cart[itemId].quantity -= 1
            } else {
                delete cart[itemId]
            }
            updateCartTotals()
        }
    }

    function updateCartTotals() {
        totalAmount = 0
        totalItems = 0
        for (var itemId in cart) {
            totalAmount += cart[itemId].price * cart[itemId].quantity
            totalItems += cart[itemId].quantity
        }
        cartModel.clear()
        for (var id in cart) {
            cartModel.append({
                itemId: id,
                name: cart[id].name,
                price: cart[id].price,
                quantity: cart[id].quantity,
                total: cart[id].price * cart[id].quantity
            })
        }
        cartUpdateTrigger = cartUpdateTrigger + 1
    }

    function getCartQuantity(itemId) {
        return cartUpdateTrigger >= 0 && cart[itemId] ? cart[itemId].quantity : 0
    }

    function createOrderData() {
        var orderItems = []
        var currentDate = new Date()

        var isStudent = Qt.application.isStudent || false
        var deliveryFee = isStudent ? 0 : 50
        var userDisplayName = Qt.application.currentUserDisplayName || "guest"

        for (var itemId in cart) {
            orderItems.push({
                name: cart[itemId].name,
                price: cart[itemId].price,
                quantity: cart[itemId].quantity,
                total: cart[itemId].price * cart[itemId].quantity
            })
        }

        return {
            restaurant: "Pratima Underground",
            restaurantIcon: "🏔️",
            items: orderItems,
            subtotal: totalAmount,
            deliveryFee: deliveryFee,
            totalAmount: totalAmount + deliveryFee,
            totalItems: totalItems,
            orderDate: Qt.formatDateTime(currentDate, "MMMM dd, yyyy"),
            orderTime: Qt.formatDateTime(currentDate, "hh:mm AP"),
            customerName: userDisplayName,
            isStudent: isStudent
        }
    }

    // Mobile gradient background
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

        // Mobile Header
        Rectangle {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: 80 * dp

            color: Qt.rgba(0.15, 0.18, 0.25, 0.9)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.1)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16 * dp
                anchors.rightMargin: 16 * dp
                spacing: 12 * dp

                Rectangle {
                    Layout.preferredWidth: 40 * dp
                    Layout.preferredHeight: 40 * dp
                    Layout.alignment: Qt.AlignVCenter
                    radius: 20 * dp
                    color: Qt.rgba(1, 1, 1, 0.08)

                    Text {
                        anchors.centerIn: parent
                        text: "←"
                        color: "#f9fafb"
                        font.pixelSize: 16 * dp
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageLoader.source = "selectrestaurant.qml"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8 * dp

                    Rectangle {
                        Layout.preferredWidth: 32 * dp
                        Layout.preferredHeight: 32 * dp
                        radius: 8 * dp
                        color: "#ef4444"

                        Text {
                            anchors.centerIn: parent
                            text: "🏔️"
                            font.pixelSize: 16 * dp
                        }
                    }

                    ColumnLayout {
                        spacing: 2 * dp

                        Text {
                            text: "PRATIMA"
                            font.family: "SF Pro Display, Segoe UI"
                            font.pixelSize: 14 * dp
                            font.weight: Font.Bold
                            color: "#f9fafb"
                        }

                        Text {
                            text: isLoadingMenu ? "Loading..." : "Nepali Cuisine"
                            font.family: "SF Pro Text, Segoe UI"
                            font.pixelSize: 10 * dp
                            color: "#ef4444"
                            font.weight: Font.Medium
                        }
                    }
                }

                // Refresh button
                Rectangle {
                    Layout.preferredWidth: 40 * dp
                    Layout.preferredHeight: 32 * dp
                    Layout.alignment: Qt.AlignVCenter
                    radius: 16 * dp
                    color: Qt.rgba(1, 1, 1, 0.08)

                    Text {
                        anchors.centerIn: parent
                        text: "🔄"
                        font.pixelSize: 12 * dp
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: loadMenuFromFirebase()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 80 * dp
                    Layout.preferredHeight: 32 * dp
                    Layout.alignment: Qt.AlignVCenter
                    radius: 16 * dp
                    color: totalItems > 0 ? "#10b981" : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4 * dp

                        Text {
                            text: "🛒"
                            font.pixelSize: 12 * dp
                        }

                        Text {
                            text: totalItems > 0 ? totalItems.toString() : "0"
                            font.family: "SF Pro Text, Segoe UI"
                            font.pixelSize: 10 * dp
                            font.weight: Font.Medium
                            color: "#f9fafb"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: cartDrawer.open()
                    }
                }
            }
        }

        // Mobile Menu Content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: parent.width
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 16 * dp

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.margins: 16 * dp
                    spacing: 8 * dp

                    Text {
                        text: "FOOD MENU"
                        font.family: "SF Pro Display, Segoe UI"
                        font.pixelSize: 24 * dp
                        font.weight: Font.Bold
                        color: "#f9fafb"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 60 * dp
                        Layout.preferredHeight: 3 * dp
                        Layout.alignment: Qt.AlignHCenter
                        radius: 2 * dp
                        color: "#ef4444"
                    }
                }

                // Loading indicator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80 * dp
                    Layout.margins: 16 * dp
                    radius: 12 * dp
                    color: Qt.rgba(1, 1, 1, 0.08)
                    visible: isLoadingMenu

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 12 * dp

                        Text {
                            text: "⏳"
                            font.pixelSize: 20 * dp
                        }

                        Text {
                            text: "Loading menu from please wait"
                            font.pixelSize: 14 * dp
                            color: "#f9fafb"
                        }
                    }
                }

                // Dynamic Menu Items from Firebase
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.margins: 16 * dp
                    spacing: 16 * dp
                    visible: !isLoadingMenu

                    Repeater {
                        model: menuItems.length

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120 * dp
                            radius: 16 * dp

                            gradient: Gradient {
                                orientation: Gradient.Vertical
                                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.08) }
                                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.03) }
                            }
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.12)

                            property var modelData: index < menuItems.length ? menuItems[index] : {}

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12 * dp
                                spacing: 12 * dp

                                Rectangle {
                                    Layout.preferredWidth: 60 * dp
                                    Layout.preferredHeight: 60 * dp
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 12 * dp
                                    color: parent.parent.modelData.color || "#6b7280"

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.parent.parent.modelData.image || "🍽️"
                                        font.pixelSize: 24 * dp
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 4 * dp

                                    Text {
                                        text: parent.parent.parent.modelData.name || "Unknown Item"
                                        font.family: "SF Pro Display, Segoe UI"
                                        font.pixelSize: 16 * dp
                                        font.weight: Font.Bold
                                        color: "#f9fafb"
                                    }

                                    Text {
                                        text: "Rs " + (parent.parent.parent.modelData.price || 0)
                                        font.family: "SF Pro Display, Segoe UI"
                                        font.pixelSize: 14 * dp
                                        font.weight: Font.Bold
                                        color: parent.parent.parent.modelData.color || "#6b7280"
                                    }

                                    Text {
                                        text: parent.parent.parent.modelData.description || "Delicious food item"
                                        font.family: "SF Pro Text, Segoe UI"
                                        font.pixelSize: 10 * dp
                                        color: "#9ca3af"
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }
                                }

                                ColumnLayout {
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 8 * dp

                                    Rectangle {
                                        Layout.preferredWidth: 36 * dp
                                        Layout.preferredHeight: 36 * dp
                                        Layout.alignment: Qt.AlignHCenter
                                        radius: 18 * dp
                                        color: "#10b981"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "+"
                                            font.pixelSize: 16 * dp
                                            font.weight: Font.Bold
                                            color: "#f9fafb"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                if (index < menuItems.length) {
                                                    var item = menuItems[index]
                                                    console.log("Adding Firebase item:", item.name)
                                                    addToCart(item.id, item.name, item.price)
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        text: index < menuItems.length ? getCartQuantity(menuItems[index].id).toString() : "0"
                                        font.family: "SF Pro Text, Segoe UI"
                                        font.pixelSize: 14 * dp
                                        font.weight: Font.Bold
                                        color: (index < menuItems.length && getCartQuantity(menuItems[index].id) > 0) ? "#ef4444" : "#f9fafb"
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 36 * dp
                                        Layout.preferredHeight: 36 * dp
                                        Layout.alignment: Qt.AlignHCenter
                                        radius: 18 * dp
                                        color: (index < menuItems.length && getCartQuantity(menuItems[index].id) > 0) ? "#ef4444" : Qt.rgba(1, 1, 1, 0.1)
                                        opacity: (index < menuItems.length && getCartQuantity(menuItems[index].id) > 0) ? 1.0 : 0.5

                                        Text {
                                            anchors.centerIn: parent
                                            text: "−"
                                            font.pixelSize: 16 * dp
                                            font.weight: Font.Bold
                                            color: "#f9fafb"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            enabled: index < menuItems.length && getCartQuantity(menuItems[index].id) > 0
                                            onClicked: {
                                                if (index < menuItems.length) {
                                                    var item = menuItems[index]
                                                    console.log("Removing Firebase item:", item.name)
                                                    removeFromCart(item.id)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // No items message
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100 * dp
                        radius: 12 * dp
                        color: Qt.rgba(1, 1, 1, 0.05)
                        visible: menuItems.length === 0 && !isLoadingMenu

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8 * dp

                            Text {
                                text: "🍽️"
                                font.pixelSize: 30 * dp
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "No items available"
                                font.pixelSize: 14 * dp
                                color: "#9ca3af"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "All menu items are currently disabled"
                                font.pixelSize: 11 * dp
                                color: "#6b7280"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                Item { Layout.preferredHeight: 20 * dp }
            }
        }

        // Mobile Bottom Cart Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: totalItems > 0 ? 60 * dp : 0
            color: Qt.rgba(0.15, 0.18, 0.25, 0.95)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.1)
            visible: totalItems > 0

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12 * dp
                spacing: 12 * dp

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2 * dp

                    Text {
                        text: totalItems + " items"
                        font.family: "SF Pro Text, Segoe UI"
                        font.pixelSize: 12 * dp
                        color: "#9ca3af"
                    }

                    Text {
                        text: "Rs " + totalAmount
                        font.family: "SF Pro Display, Segoe UI"
                        font.pixelSize: 16 * dp
                        font.weight: Font.Bold
                        color: "#10b981"
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 100 * dp
                    Layout.preferredHeight: 36 * dp
                    radius: 18 * dp
                    color: "#ef4444"

                    Text {
                        anchors.centerIn: parent
                        text: "View Cart"
                        font.family: "SF Pro Text, Segoe UI"
                        font.pixelSize: 12 * dp
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: cartDrawer.open()
                    }
                }
            }
        }
    }

    // Mobile Cart Drawer (keep existing code)
    Drawer {
        id: cartDrawer
        width: parent.width
        height: parent.height * 0.8
        edge: Qt.BottomEdge

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0.15, 0.18, 0.25, 0.98)
            radius: 20 * dp

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16 * dp
                spacing: 16 * dp

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12 * dp

                    Rectangle {
                        Layout.preferredWidth: 4 * dp
                        Layout.preferredHeight: 30 * dp
                        radius: 2 * dp
                        color: "#ef4444"
                    }

                    Text {
                        text: "Your Cart (" + totalItems + " items)"
                        font.family: "SF Pro Display, Segoe UI"
                        font.pixelSize: 20 * dp
                        font.weight: Font.Bold
                        color: "#f9fafb"
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: 32 * dp
                        Layout.preferredHeight: 32 * dp
                        radius: 16 * dp
                        color: Qt.rgba(1, 1, 1, 0.1)

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            font.pixelSize: 18 * dp
                            color: "#f9fafb"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: cartDrawer.close()
                        }
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: parent.width
                    clip: true

                    ListView {
                        model: ListModel { id: cartModel }
                        spacing: 12 * dp

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 80 * dp
                            radius: 12 * dp
                            color: Qt.rgba(1, 1, 1, 0.05)
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.1)

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12 * dp
                                spacing: 12 * dp

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4 * dp

                                    Text {
                                        text: model.name
                                        font.family: "SF Pro Text, Segoe UI"
                                        font.pixelSize: 14 * dp
                                        font.weight: Font.Bold
                                        color: "#f9fafb"
                                    }

                                    Text {
                                        text: "Rs " + model.price + " × " + model.quantity
                                        font.family: "SF Pro Text, Segoe UI"
                                        font.pixelSize: 12 * dp
                                        color: "#9ca3af"
                                    }
                                }

                                Text {
                                    text: "Rs " + model.total
                                    font.family: "SF Pro Text, Segoe UI"
                                    font.pixelSize: 16 * dp
                                    font.weight: Font.Bold
                                    color: "#ef4444"
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60 * dp
                    radius: 12 * dp
                    color: Qt.rgba(1, 1, 1, 0.1)
                    border.width: 2
                    border.color: "#ef4444"

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 12 * dp

                        Text {
                            text: "Total Amount"
                            font.family: "SF Pro Text, Segoe UI"
                            font.pixelSize: 16 * dp
                            font.weight: Font.Medium
                            color: "#9ca3af"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "Rs " + totalAmount
                            font.family: "SF Pro Display, Segoe UI"
                            font.pixelSize: 20 * dp
                            font.weight: Font.Bold
                            color: "#ef4444"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50 * dp
                    radius: 25 * dp
                    color: totalItems > 0 ? "#ef4444" : "#6b7280"
                    enabled: totalItems > 0

                    scale: orderMouseArea.pressed && parent.enabled ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8 * dp

                        Text {
                            text: "🚀"
                            font.pixelSize: 16 * dp
                        }

                        Text {
                            text: totalItems > 0 ? "Place Order" : "Cart is Empty"
                            font.family: "SF Pro Text, Segoe UI"
                            font.pixelSize: 16 * dp
                            font.weight: Font.Bold
                            color: "#ffffff"
                        }
                    }

                    MouseArea {
                        id: orderMouseArea
                        anchors.fill: parent
                        enabled: parent.enabled

                        onClicked: {
                            console.log("Placing order with", totalItems, "Firebase items")
                            var orderData = createOrderData()
                            Qt.application.currentOrder = orderData
                            cartDrawer.close()
                            pageLoader.source = "paymentpage.qml"
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("📱 Pratima Menu (Firebase-connected) loaded")
        console.log("👤 User: Sumit-51")
        console.log("🕒 Time: 2025-08-03 09:30:48")

        // Load menu from Firebase on page load
        loadMenuFromFirebase()
    }
}
