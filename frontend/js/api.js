// API_BASE relative rakha hai — koi bhi domain pe kaam karega
// Nginx /api/* requests ko Backend ALB pe proxy karta hai
const API_BASE = '/api';

const Api = {
  _headers() {
    const token = localStorage.getItem('token');
    return {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    };
  },

  async request(method, path, body = null) {
    const opts = { method, headers: this._headers() };
    if (body) opts.body = JSON.stringify(body);
    const res  = await fetch(`${API_BASE}${path}`, opts);
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Request failed');
    return data;
  },

  get:  (path)       => Api.request('GET',  path),
  post: (path, body) => Api.request('POST', path, body),
  put:  (path, body) => Api.request('PUT',  path, body),

  companyRegister:     (d) => Api.post('/auth/company/send-otp', d),
  companyVerifyOtp:    (d) => Api.post('/auth/company/verify-otp', d),
  companyLogin:        (d) => Api.post('/auth/company/login', d),
  userRegister:        (d) => Api.post('/auth/user/send-otp', d),
  userVerifyOtp:       (d) => Api.post('/auth/user/verify-otp', d),
  userLogin:           (d) => Api.post('/auth/user/login', d),

  getInterviews:        ()   => Api.get('/interviews/'),
  getInterview:         (id) => Api.get(`/interviews/${id}`),
  postInterview:        (d)  => Api.post('/interviews/', d),
  getCompanyInterviews: ()   => Api.get('/interviews/company/mine'),
  closeInterview:       (id) => Api.put(`/interviews/${id}/close`),

  book:              (d)  => Api.post('/bookings/', d),
  myBookings:        ()   => Api.get('/bookings/my'),
  cancelBooking:     (id) => Api.put(`/bookings/${id}/cancel`),
  interviewBookings: (id) => Api.get(`/bookings/interview/${id}`),

  mockChat: (messages, mode = 'interview') =>
    Api.post('/mock/chat', { messages, mode }),
};
