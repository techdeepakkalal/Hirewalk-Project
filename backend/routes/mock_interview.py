from flask import Blueprint, request, jsonify
import requests
from config import Config
from utils.jwt_helper import token_required

mock_bp = Blueprint('mock', __name__)

SYSTEM_INTERVIEW = """You are an expert technical interviewer at a top tech company. Your job:
1. Greet the candidate warmly and ask what role they are preparing for.
2. Conduct a structured mock interview — ask ONE focused question at a time.
3. Mix technical questions with behavioral ones (STAR method).
4. After each answer give brief 2-3 sentence feedback starting with "Feedback:".
5. Adapt difficulty based on answers.
6. After 5-6 exchanges give a final overall assessment with strengths and areas to improve.
Keep tone professional but encouraging."""

SYSTEM_QA = """You are a helpful career and technical advisor for job seekers. You help with:
- Career advice and interview tips
- Technical concepts (coding, cloud, DevOps, databases, etc.)
- Resume and profile guidance
- Salary negotiation tips
- Any doubts or questions about interviews, jobs, or tech topics
Be concise, friendly and genuinely helpful. Answer questions directly.
Do NOT conduct a mock interview. Just answer what the user asks."""

@mock_bp.route('/chat', methods=['POST'])
@token_required(role='user')
def chat():
    d        = request.get_json() or {}
    messages = d.get('messages', [])
    mode     = d.get('mode', 'interview')

    if not isinstance(messages, list):
        return jsonify({'error': 'messages must be a list'}), 400

    # Pick system prompt based on mode
    system_prompt = SYSTEM_QA if mode == 'qa' else SYSTEM_INTERVIEW

    try:
        resp = requests.post(
            'https://api.groq.com/openai/v1/chat/completions',
            headers={
                'Authorization': f'Bearer {Config.GROQ_API_KEY}',
                'Content-Type':  'application/json'
            },
            json={
                'model':    Config.GROQ_MODEL,
                'messages': [{'role': 'system', 'content': system_prompt}, *messages],
                'max_tokens':  600,
                'temperature': 0.7
            },
            timeout=30
        )
        if resp.status_code != 200:
            return jsonify({'error': 'AI service unavailable', 'detail': resp.text}), 502
        return jsonify({'message': resp.json()['choices'][0]['message']['content']})
    except requests.Timeout:
        return jsonify({'error': 'AI service timed out, please retry'}), 504
    except Exception as e:
        return jsonify({'error': str(e)}), 500