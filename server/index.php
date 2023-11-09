<?php
require './vendor/autoload.php';
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS, DELETE');
header("Access-Control-Allow-Headers: X-Requested-With");
//  Read https://github.com/nikic/FastRoute
$dispatcher = FastRoute\simpleDispatcher(function(FastRoute\RouteCollector $r) {
    $r->get('/', 'loadHome');
    $r->get('/queue', 'getAllQueues');
    $r->post('/create', 'createQueue');
    // {name} can be any alphanumeric string
    // {id} can be any number
    $r->get('/queue/{name:\w+}', 'getQueue'); 
    $r->delete('/queue/{id:\d+}', 'deleteQueue');
    $r->post('/join/{id:\d+}', 'joinQueue');
    $r->post('/update/{id:\d+}', 'updateQueue');
    $r->get("/ping", function() {
        echo "pong";
    });
    // Create routes for receiving a GET and POST request at /theme
    $r->get('/theme', 'getTheme');
    $r->post('/theme', 'setTheme');
});

$db = new SQLite3('queue.sqlite');
setup($db);
// Fetch method and URI from somewhere
$httpMethod = $_SERVER['REQUEST_METHOD'];
$uri = $_SERVER['REQUEST_URI'];

// Strip query string, e.g. (?foo=bar) and decode URI
if (false !== $pos = strpos($uri, '?')) {
    $uri = substr($uri, 0, $pos);
}

// Unused variable
$uri = rawurldecode($uri);

$routeInfo = $dispatcher->dispatch($httpMethod, $uri);
switch ($routeInfo[0]) {
    case FastRoute\Dispatcher::NOT_FOUND:
        // ... 404 Not Found
        break;
    case FastRoute\Dispatcher::METHOD_NOT_ALLOWED:
        $allowedMethods = $routeInfo[1];
        // ... 405 Method Not Allowed
        break;
    case FastRoute\Dispatcher::FOUND:
        $handler = $routeInfo[1];
        $vars = $routeInfo[2];
        $handler($db, $vars);
        break;
}

function setup($db) {
    // run tables.sql using the $db
    $sql = file_get_contents('tables.sql');
    $db->exec($sql);
}

function loadHome() {
    echo file_get_contents('index.html');
}

function getAllQueues($db) {
    $sql = 'SELECT * FROM queue';
    $result = $db->query($sql);

    $queues = [];
    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $queues[] = $row;
    }

    echo_json($queues);
}

function createQueue($db, $vars) {
    /** @var string */
    $name = $_POST['name'];

    $sql = 'INSERT INTO queue (name, icon, current, last_position) VALUES (:name, \'\', 0, 0)';
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':name', $name);
    $stmt->execute();
    $id = $db->lastInsertRowID();
    echo_json(['id' => $id]);
}

// GetQueue
function getQueue($db, $vars) {
    $sql = 'SELECT * FROM queue WHERE name = :name';
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':name', $vars['name']);
    $result = $stmt->execute();

    if ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        echo_json($row);
    } else {
        header('HTTP/1.1 404 Not Found');
        echo 'Queue not found';
    }
}

// UpdateQueue
function updateQueue($db, $vars) {
    $sql = 'UPDATE queue SET name = :name, current = :current, last_position = :last_position, icon = :icon WHERE id = :id';
    $stmt = $db->prepare($sql);
    $stmt->bindParam(":id", $vars['id']);
    $stmt->bindParam(":name", $_POST['name']);
    $stmt->bindParam(":current", $_POST['current']);
    $stmt->bindParam(":icon", $_POST['icon']);
    $stmt->bindParam(":last_position", $_POST['last_position']);
    $stmt->execute();
}

function deleteQueue($db, $vars) {
    $sql = 'DELETE FROM queue WHERE id = :id';
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':id', $vars['id']);
    $stmt->execute();

    header('HTTP/1.1 204 No Content');
}

function demand($key) {
    if (!isset($_REQUEST[$key])) {
        header('HTTP/1.1 400 Bad Request');
        echo "$key is required";
        exit();
    }
    return $_REQUEST[$key];
}
function joinQueue($db, $vars) {
    /** @var string */
    $id = $vars['id'];
    $sql = 'SELECT last_position FROM queue WHERE id = :id';
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':id', $id);
    $result = $stmt->execute();

    if ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        $new_pos = $row['last_position'] + 1;
        $update = 'UPDATE queue SET last_position = :last_pos WHERE id = :id';
        $stmt2 = $db->prepare($update);
        $stmt2->bindParam(':id', $id);
        $stmt2->bindParam(':last_pos', $new_pos);
        $result = $stmt2->execute();
        echo_json(['number'=>$new_pos]);
    } else {
        header('HTTP/1.1 404 Not Found');
        echo 'Queue not found';
    }
}

function clue(string $type) {
    if ($type == "json") {
        header('Content-Type: application/json');
    }
}

function echo_json(mixed $json) {
    clue("json");
    echo json_encode($json);
}

function getTheme($db) {
    // query the first record in the theme table
    // return the result as json
    $id=0;
    $sql = 'SELECT * FROM theme WHERE id=:id';
    $stmt = $db->prepare($sql);
    $stmt->bindParam(':id', $id);
    $result = $stmt->execute()->fetchArray(SQLITE3_ASSOC);
    echo json_encode(array(
        'id' => $result['id'],
        'seed' => $result['seed'],
        'brightness' => $result['brightness'],
        'appBackground' => $result['appBackground'],

        'appBar' => array(
            'background' => $result['appBarBackground'],
            'foreground' => $result['appBarForeground'],
        ),
        'queueItem' => array(
            'background' => $result['queueItemBackground'],
            'foreground' => $result['queueItemForeground'],
        ),
    ));

}
// function getStyle($db, $vars) {
//     $sql = 'SELECT id, name FROM style WHERE name IN ("app.bg", "appBarColor.fg", "appBarColor.bg", "queueItemColor.bg", "queueItemColor.fg", "seed", "brightness")';
//     $stmt = $db->prepare($sql);
//     $result = $stmt->execute();
//     // $rows = array();
//     // while ($row = ) {
//     //     $rows[$row] = $row;
//     // }

//     echo_json($result->fetchArray(SQLITE3_ASSOC));
// }

function setTheme($db) {
    $theme = json_decode($_POST['theme'], true);
    file_put_contents('theme.json', json_encode($theme, JSON_PRETTY_PRINT));
    // Create a replace into stmt for the theme @ id =0
    $sql = 'REPLACE INTO theme (id, seed, brightness, appBackground, appBarBackground, appBarForeground, queueItemBackground, queueItemForeground) VALUES (:id, :seed, :brightness, :appBackground, :appBarBackground, :appBarForeground, :queueItemBackground, :queueItemForeground)';
    $stmt = $db->prepare($sql);
    $id = "0";
    $stmt->bindParam(':id', $id);
    $stmt->bindParam(':seed', $theme['seed']);
    $stmt->bindParam(':brightness', $theme['brightness']);
    $stmt->bindParam(':appBackground', $theme['appBackground']);
    $stmt->bindParam(':appBarBackground', $theme['appBar']['background']);
    $stmt->bindParam(':appBarForeground', $theme['appBar']['foreground']);
    $stmt->bindParam(':queueItemBackground', $theme['queueItem']['background']);
    $stmt->bindParam(':queueItemForeground', $theme['queueItem']['foreground']);
    $stmt->execute();
}
