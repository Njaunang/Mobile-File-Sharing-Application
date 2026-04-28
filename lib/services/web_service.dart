import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class WebService {
  HttpServer? _server;
  bool _isRunning = false;
  String _ip = '';
  int _port = 8080;
  String _pin = '';

  // List of files to share: Map<String, File> where key is a unique ID
  Map<String, File> _sharedFiles = {};

  bool get isRunning => _isRunning;
  String get address => 'http://$_ip:$_port';
  String get pin => _pin;

  Future<bool> startServer(
    String ip, {
    int port = 8080,
    required String pin,
  }) async {
    if (_isRunning) return true;

    try {
      _ip = ip;
      _port = port;
      _pin = pin;
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      _isRunning = true;

      _server!.listen(_handleRequest);
      debugPrint('Web Server started at http://$_ip:$_port with PIN $_pin');
      return true;
    } catch (e) {
      debugPrint('Error starting web server: $e');
      return false;
    }
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
    _isRunning = false;
  }

  void updateSharedFiles(List<File> files) {
    _sharedFiles.clear();
    for (var file in files) {
      final id = _generateId(file.path);
      _sharedFiles[id] = file;
    }
  }

  String _generateId(String path) {
    return base64Url.encode(utf8.encode(p.basename(path))).replaceAll('=', '');
  }

  void _handleRequest(HttpRequest request) async {
    final response = request.response;
    final path = request.uri.path;

    try {
      if (path == '/') {
        _serveHtml(request);
      } else if (path == '/api/files') {
        _handleApiFiles(request);
      } else if (path == '/api/auth') {
        _handleApiAuth(request);
      } else if (path.startsWith('/download/')) {
        _handleDownload(request);
      } else {
        response.statusCode = HttpStatus.notFound;
        await response.close();
      }
    } catch (e) {
      debugPrint('Request error: $e');
      response.statusCode = HttpStatus.internalServerError;
      await response.close();
    }
  }

  void _serveHtml(HttpRequest request) {
    final response = request.response;
    response.headers.contentType = ContentType.html;
    response.write(_getHtmlContent());
    response.close();
  }

  void _handleApiFiles(HttpRequest request) {
    final response = request.response;

    // Check PIN in header or cookie (simplified for local)
    final clientPin =
        request.headers.value('x-pin') ?? request.uri.queryParameters['pin'];
    if (clientPin != _pin) {
      response.statusCode = HttpStatus.unauthorized;
      response.write(jsonEncode({'error': 'Unauthorized'}));
      response.close();
      return;
    }

    final filesJson = _sharedFiles.entries.map((e) {
      final file = e.value;
      return {
        'id': e.key,
        'name': p.basename(file.path),
        'size': file.lengthSync(),
        'type': _getFileType(file.path),
      };
    }).toList();

    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(filesJson));
    response.close();
  }

  void _handleApiAuth(HttpRequest request) async {
    final response = request.response;
    if (request.method != 'POST') {
      response.statusCode = HttpStatus.methodNotAllowed;
      response.close();
      return;
    }

    final body = await utf8.decoder.bind(request).join();
    final data = jsonDecode(body);
    final providedPin = data['pin'];

    if (providedPin == _pin) {
      response.headers.contentType = ContentType.json;
      response.write(jsonEncode({'status': 'success'}));
    } else {
      response.statusCode = HttpStatus.unauthorized;
      response.write(jsonEncode({'status': 'fail', 'message': 'Invalid PIN'}));
    }
    response.close();
  }

  void _handleDownload(HttpRequest request) async {
    final response = request.response;
    final id = request.uri.path.replaceFirst('/download/', '');
    final clientPin = request.uri.queryParameters['pin'];

    if (clientPin != _pin) {
      response.statusCode = HttpStatus.unauthorized;
      response.close();
      return;
    }

    final file = _sharedFiles[id];
    if (file == null || !await file.exists()) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }

    final fileName = p.basename(file.path);
    response.headers.add(
      "Content-Disposition",
      'attachment; filename="$fileName"',
    );
    response.headers.contentType = ContentType.binary;
    response.contentLength = file.lengthSync();

    await response.addStream(file.openRead());
    await response.close();
  }

  String _getFileType(String path) {
    final ext = p.extension(path).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext))
      return 'image';
    if (['.mp4', '.mkv', '.mov', '.avi'].contains(ext)) return 'video';
    if (['.mp3', '.wav', '.m4a'].contains(ext)) return 'audio';
    if (['.pdf', '.doc', '.docx', '.txt'].contains(ext)) return 'document';
    if (ext == '.apk') return 'apk';
    return 'file';
  }

  String _getHtmlContent() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Local Sharer - Secure Transfer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #6366f1;
            --primary-light: #818cf8;
            --bg: #f8fafc;
            --card: #ffffff;
            --text: #0f172a;
            --text-sec: #64748b;
            --success: #22c55e;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { 
            font-family: 'Plus Jakarta Sans', sans-serif; 
            background-color: var(--bg); 
            color: var(--text);
            min-height: 100vh;
            line-height: 1.5;
        }
        .navbar {
            padding: 20px 40px;
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(12px);
            position: sticky;
            top: 0;
            z-index: 100;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid rgba(0,0,0,0.05);
        }
        .logo { font-weight: 800; font-size: 1.5rem; color: var(--primary); letter-spacing: -0.5px; }
        
        .container { 
            max-width: 1000px; 
            margin: 0 auto;
            padding: 40px 20px; 
        }

        /* Auth Card */
        #auth-section {
            background: var(--card);
            padding: 60px 40px;
            border-radius: 40px;
            box-shadow: 0 20px 50px -12px rgba(0,0,0,0.05);
            text-align: center;
            max-width: 450px;
            margin: 100px auto 0;
            animation: fadeIn 0.6s ease-out;
        }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        
        #auth-section h2 { font-size: 2rem; margin-bottom: 12px; font-weight: 800; }
        .pin-container { display: flex; gap: 12px; justify-content: center; margin: 32px 0; }
        .pin-digit {
            width: 56px; height: 64px;
            border: 2px solid #e2e8f0;
            border-radius: 16px;
            font-size: 1.5rem;
            font-weight: 800;
            text-align: center;
            outline: none;
            transition: all 0.2s;
        }
        .pin-digit:focus { border-color: var(--primary); box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1); }

        /* File Section */
        #file-section { display: none; animation: fadeIn 0.6s ease-out; }
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px; }
        .section-header h2 { font-weight: 800; font-size: 1.75rem; }

        button {
            background: var(--primary);
            color: white;
            padding: 16px 32px;
            border-radius: 18px;
            border: none;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 10px 20px -5px rgba(99, 102, 241, 0.3);
            font-family: inherit;
        }
        button:hover {
            background: var(--primary-light);
            transform: translateY(-3px);
            box-shadow: 0 15px 30px -10px rgba(99, 102, 241, 0.4);
        }
        button:active {
            transform: translateY(-1px);
        }

        .btn-all {
            padding: 12px 24px;
            border-radius: 14px;
        }

        .file-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 24px;
        }
        .file-card {
            background: var(--card);
            padding: 20px;
            border-radius: 28px;
            display: flex;
            align-items: center;
            gap: 20px;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02);
            border: 1px solid rgba(0,0,0,0.03);
            transition: all 0.3s;
            text-decoration: none;
            color: inherit;
        }
        .file-card:hover { 
            transform: translateY(-6px); 
            box-shadow: 0 12px 30px -10px rgba(0,0,0,0.08); 
            border-color: var(--primary);
        }
        .file-icon {
            width: 64px; height: 64px;
            background: #f1f5f9;
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            flex-shrink: 0;
        }
        .file-info { flex-grow: 1; min-width: 0; }
        .file-name { font-weight: 700; font-size: 1rem; margin-bottom: 2px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .file-size { font-size: 0.85rem; color: var(--text-sec); }
        
        .download-icon { color: var(--primary); font-size: 1.25rem; margin-left: 8px; }

        .empty-state { text-align: center; padding: 100px 40px; color: var(--text-sec); }
        .empty-state div { font-size: 4rem; margin-bottom: 20px; }

        @media (max-width: 600px) {
            .navbar { padding: 15px 20px; }
            .pin-digit { width: 48px; height: 56px; }
            .file-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="logo">
          Local Sharer
        </div>
        <div id="status-badge" style="display: none; background: #dcfce7; color: var(--success); padding: 6px 14px; border-radius: 20px; font-size: 0.8rem; font-weight: 700;">Connected</div>
    </nav>

    <div class="container">
        <div id="auth-section">
            <h2>Security Check</h2>
            <p style="color: var(--text-sec);">Enter the 4-digit PIN shown on the app</p>
            <div class="pin-container">
                <input type="text" class="pin-digit" maxlength="1" onkeyup="moveNext(this, 1)">
                <input type="text" class="pin-digit" maxlength="1" onkeyup="moveNext(this, 2)">
                <input type="text" class="pin-digit" maxlength="1" onkeyup="moveNext(this, 3)">
                <input type="text" class="pin-digit" maxlength="1" onkeyup="moveNext(this, 4)">
            </div>
            <button onclick="login()" style="width: auto; padding: 16px 40px;">Unlock Files</button>
            <p id="error-msg" style="color: #ef4444; margin-top: 16px; font-size: 0.85rem; display: none;">Invalid PIN. Please check your phone.</p>
        </div>

        <div id="file-section">
            <div class="section-header">
                <h2>Shared Files</h2>
                <button class="btn-all" onclick="downloadAll()">Download All</button>
            </div>
            <div id="files-container" class="file-grid"></div>
            <div id="empty-msg" class="empty-state" style="display: none;">
                <div>📦</div>
                <h3>No files shared yet</h3>
                <p>Add files to the web share basket on your phone</p>
            </div>
        </div>
    </div>

    <script>
        let sessionPin = '';
        const digits = document.querySelectorAll('.pin-digit');

        function moveNext(el, index) {
            if (el.value.length === 1 && index < 4) {
                digits[index].focus();
            }
            if (el.value.length === 1 && index === 4) {
                login();
            }
        }

        async function login() {
            const pin = Array.from(digits).map(d => d.value).join('');
            if (pin.length < 4) return;

            const res = await fetch('/api/auth', {
                method: 'POST',
                body: JSON.stringify({ pin: pin })
            });
            const data = await res.json();
            
            if (data.status === 'success') {
                sessionPin = pin;
                document.getElementById('auth-section').style.display = 'none';
                document.getElementById('file-section').style.display = 'block';
                document.getElementById('status-badge').style.display = 'block';
                loadFiles();
            } else {
                document.getElementById('error-msg').style.display = 'block';
                digits.forEach(d => { d.value = ''; d.style.borderColor = '#ef4444'; });
                digits[0].focus();
            }
        }

        let sharedFilesList = [];

        async function loadFiles() {
            const res = await fetch('/api/files?pin=' + sessionPin);
            sharedFilesList = await res.json();
            const container = document.getElementById('files-container');
            const emptyMsg = document.getElementById('empty-msg');
            
            container.innerHTML = '';
            if (sharedFilesList.length === 0) {
                emptyMsg.style.display = 'block';
                return;
            }

            emptyMsg.style.display = 'none';
            sharedFilesList.forEach(file => {
                const card = document.createElement('a');
                card.className = 'file-card';
                card.href = `/download/\${file.id}?pin=\${sessionPin}`;
                card.innerHTML = `
                    <div class="file-icon">\${getIcon(file.type)}</div>
                    <div class="file-info">
                        <div class="file-name" title="\${file.name}">\${file.name}</div>
                        <div class="file-size">\${formatSize(file.size)}</div>
                    </div>
                    <div class="download-icon">↓</div>
                `;
                container.appendChild(card);
            });
        }

        function downloadAll() {
            sharedFilesList.forEach((file, index) => {
                setTimeout(() => {
                    const link = document.createElement('a');
                    link.href = `/download/\${file.id}?pin=\${sessionPin}`;
                    link.download = file.name;
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                }, index * 1000); // 1s interval to prevent browser block
            });
        }

        function getIcon(type) {
            switch(type) {
                case 'image': return '🖼️';
                case 'video': return '🎬';
                case 'audio': return '🎵';
                case 'document': return '📄';
                case 'apk': return '🤖';
                default: return '📁';
            }
        }

        function formatSize(bytes) {
            if (bytes === 0) return '0 B';
            const k = 1024;
            const sizes = ['B', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + ' ' + sizes[i];
        }
    </script>
</body>
</html>
''';
  }
}
