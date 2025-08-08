import os
from flask import Flask, render_template, jsonify
from datetime import datetime

app = Flask(__name__)

# 環境變數配置
app.config['DEBUG'] = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
app.config['PORT'] = int(os.environ.get('PORT', 8087))

@app.route('/')
def index():
    """主頁面"""
    try:
        return render_template('index.html')
    except Exception as e:
        app.logger.error(f"Error rendering index page: {str(e)}")
        return "Internal Server Error", 500

@app.route('/health')
def health_check():
    """健康檢查端點"""
    try:
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'service': 'Flask Azure DevOps Test App'
        }), 200
    except Exception as e:
        app.logger.error(f"Health check error: {str(e)}")
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

@app.route('/api/info')
def app_info():
    """應用程式基本資訊"""
    try:
        return jsonify({
            'name': 'Flask Azure DevOps 專案',
            'version': '1.0.0',
            'description': '用於測試 Azure DevOps CI/CD pipeline 的 Flask 應用程式',
            'python_version': os.sys.version,
            'environment': os.environ.get('FLASK_ENV', 'production'),
            'timestamp': datetime.now().isoformat()
        }), 200
    except Exception as e:
        app.logger.error(f"App info error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.errorhandler(404)
def not_found(error):
    """404 錯誤處理"""
    return jsonify({'error': 'Page not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    """500 錯誤處理"""
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    port = app.config['PORT']
    debug = app.config['DEBUG']
    
    app.run(
        host='0.0.0.0',
        port=port,
        debug=debug
    )