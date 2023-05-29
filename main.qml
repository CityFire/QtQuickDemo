import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.VirtualKeyboard 2.4
import Qt.labs.settings 1.0
import QtQuick.LocalStorage 2.0

Window {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Rectangle {
        id: root
        color: settings.color
        property alias mouseArea: mouseArea
        width: 320
        height: 240
        Settings {
            id: settings
            property color color: '#000000'
            property alias color: root.color
            category: 'window'
            property alias x: window.x
            property alias y: window.x
            property alias width: window.width
            property alias height: window.height
        }
        function storeSettings() {
            settings.color = root.color
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                root.color = Qt.hsla(Math.random(), 0.5, 0.5, 1.0);
                storeSettings();
//                Qt.quit()
            }
        }

        Text {
            anchors.centerIn: parent
            text: "我爱你🇨🇳"
        }
    }

    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: window.height
        width: window.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: window.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

//    Item {
//        Component.onCompleted: {
//            var db = LocalStorage.openDatabaseSync("MyExample", "1.0", "Example database", 10000);
//            db.transaction( function(tx) {
//                var result = tx.executeSql('select * from notes');
//                for (var i = 0; i < result.rows.length; i++) {
//                    print(result.rows[i].text);
//                }
//            });
//        }
//    }

    Item {
        width: 400
        height: 400
        Rectangle {
            id: crazy
            objectName: 'crazy'
            width: 100
            height: 100
            x: 50
            y: 50
            color: "#53d769"
            border.color: Qt.lighter(color, 1.1)
            Text {
                anchors.centerIn: parent
                text: Math.round(parent.x) + '/' + Math.round(parent.y)
            }
            MouseArea {
                anchors.fill: parent
                drag.target: parent
            }
        }
    }

    Item {
        // 数据库对象的引用
        property var db;
        function initDatabase() {
            // 初始化数据库对象
            print('initDatabase()')
            db = LocalStorage.openDatabaseSync("CrazyBox", "1.0", "A box who remembers its position", 100000);
            db.transaction( function(tx) {
                 print('... create table')
                 tx.executeSql('CREATE TABLE IF NOT EXISTS data(name TEXT, value TEXT)');
            });
        }
        function storeData() {
            // 将数据保存到数据库
            print('storeData()')
            if (!db) { return; }
            db.transaction( function(tx) {
                print('... check if a crazy object exists')
                var result = tx.executeSql('SELECT * from data where name = "crazy"');// SELECT COUNT(*) from data where name = "crazy"
                // 创建一个包含需要保存的数据的对象，之后需要将这个对象转换成 JSON
                var obj = { x: crazy.x, y: crazy.y };
                if (result.rows.length === 1) { // 已有数据，更新
                    print('... crazy exists, update it')
                    result = tx.executeSql('UPDATE data set value=? where name="crazy"', [JSON.stringify(obj)]);
                } else { // 没有数据，插入
                    print('... crazy does not exists, create it')
                    result = tx.executeSql('INSERT INTO data VALUES (?,?)', ['crazy', JSON.stringify(obj)]);
                }
            });
        }
        function readData() {
            // 从数据库读取数据并使用数据
            print('readData()')
            if (!db) { return; }
            db.transaction( function(tx) {
                print('... read crazy object')
                var result = tx.executeSql('select * from data where name="crazy"');
                if (result.rows.length === 1) {
                    print('... update crazy geometry')
                    // 读取数据
                    var value = result.rows[0].value;
                    // 转换成 JS 对象
                    var obj = JSON.parse(value)
                    // 将数据应用到矩形对象
                    crazy.x = obj.x;
                    crazy.y = obj.y;
                }
            });
        }
        Component.onCompleted: {
            initDatabase();
            readData();
        }
        Component.onDestruction: {
            storeData();
        }
    }
}


