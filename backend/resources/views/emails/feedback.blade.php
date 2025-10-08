<h2>New Feedback</h2>
<p><strong>User ID:</strong> {{ $user_id ?? 'guest' }}</p>
<p><strong>Contact:</strong> {{ $contact ?? '—' }}</p>
<p><strong>IP:</strong> {{ $ip ?? 'n/a' }}</p>
<p><strong>User Agent:</strong> {{ $user_agent ?? 'n/a' }}</p>
<p><strong>Message:</strong></p>
<pre style="white-space:pre-wrap;font-family:monospace;">{{ $message }}</pre>
<p>Submitted at: {{ $submitted_at ?? now() }}</p>
