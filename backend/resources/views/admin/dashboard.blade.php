@extends('admin.layout')
@section('content')
<div class="space-y-8">
	<div>
		<h1 class="text-2xl font-semibold tracking-tight">Табло</h1>
		<p class="text-sm text-muted-foreground mt-1">Обзор на системата и активността.</p>
	</div>
	<div class="grid gap-6 md:grid-cols-4">
		<div class="p-4 rounded-lg border bg-white dark:bg-neutral-900">
			<p class="text-xs uppercase tracking-wide text-slate-500 dark:text-slate-400">Новини</p>
			<p class="mt-2 text-3xl font-semibold" id="statNews">—</p>
		</div>
		<div class="p-4 rounded-lg border bg-white dark:bg-neutral-900">
			<p class="text-xs uppercase tracking-wide text-slate-500 dark:text-slate-400">Събития</p>
			<p class="mt-2 text-3xl font-semibold" id="statEvents">—</p>
		</div>
		<div class="p-4 rounded-lg border bg-white dark:bg-neutral-900">
			<p class="text-xs uppercase tracking-wide text-slate-500 dark:text-slate-400">Потребители</p>
			<p class="mt-2 text-3xl font-semibold" id="statUsers">—</p>
		</div>
		<div class="p-4 rounded-lg border bg-white dark:bg-neutral-900">
			<p class="text-xs uppercase tracking-wide text-slate-500 dark:text-slate-400">Регистрации (общо)</p>
			<p class="mt-2 text-3xl font-semibold" id="statRegs">—</p>
		</div>
	</div>
	<div class="grid gap-6 md:grid-cols-2">
		<div class="p-4 rounded-lg border bg-white dark:bg-neutral-900">
			<h2 class="text-sm font-medium mb-2">Активност (Новини / Събития)</h2>
			<canvas id="chartContent" height="160" class="w-full"></canvas>
		</div>
		<div class="p-4 rounded-lg border bg-white dark:bg-neutral-900">
			<h2 class="text-sm font-medium mb-2">Регистрации по дни</h2>
			<canvas id="chartRegs" height="160" class="w-full"></canvas>
		</div>
	</div>
	<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
	<script>
	async function fetchStats(){
		const r = await fetch('/api/heartbeat');
		const j = await r.json();
		document.getElementById('statUsers').textContent = j.users_count ?? '—';
		// Extended stats via lightweight endpoints (fallback placeholders for now)
		const more = await fetch('/admin/stats/summary').then(r=> r.json()).catch(()=>({}));
		document.getElementById('statNews').textContent = more.news ?? '—';
		document.getElementById('statEvents').textContent = more.events ?? '—';
		document.getElementById('statRegs').textContent = more.registrations ?? '—';
		buildCharts(more.charts || {});
	}
	let chartA, chartB;
	function buildCharts(data){
		const ctxA=document.getElementById('chartContent');
		const ctxB=document.getElementById('chartRegs');
		const labels = data.labels || [];
		const news = data.news||[]; const events=data.events||[];
		const regs = data.registrations||[];
		if(chartA) chartA.destroy(); if(chartB) chartB.destroy();
		chartA=new Chart(ctxA,{type:'line',data:{labels,datasets:[{label:'Новини',data:news,borderColor:'#2563eb',tension:.3},{label:'Събития',data:events,borderColor:'#16a34a',tension:.3}]},options:{responsive:true,plugins:{legend:{position:'bottom'}}}});
		chartB=new Chart(ctxB,{type:'bar',data:{labels,datasets:[{label:'Регистрации',data:regs,backgroundColor:'#9333ea'}]},options:{responsive:true,plugins:{legend:{display:false}}}});
	}
	fetchStats();
	</script>
</div>
@endsection
