<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\News;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class NewsAdminController extends Controller
{
    public function index(Request $request) {
        $q = News::with('images');
        if($s = $request->query('search')){ $q->where('title','like',"%$s%"); }
        // Sorting
        $sortable = ['id','title','created_at','status'];
        $sort = $request->query('sort'); $dir = $request->query('dir') === 'asc' ? 'asc' : ($request->query('dir') === 'desc' ? 'desc' : null);
        if($sort && in_array($sort,$sortable) && $dir){
            $q->orderBy($sort,$dir);
        } else {
            $q->latest();
        }
        $items = $q->paginate(15)->withQueryString();
        // If request expects JSON (e.g. fetch) return structured data
        if($request->wantsJson()) {
            return response()->json([
                'html' => view('admin.news._table', compact('items'))->render(),
                'pagination' => (string) $items->links(),
                'sort' => $sort,
                'dir' => $dir,
            ]);
        }
        // If only the fragment requested (e.g. ?fragment=table) return partial blade
        if($request->query('fragment') === 'table') {
            return view('admin.news._table', compact('items'));
        }
        return view('admin.news.index', compact('items'));
    }
    public function create() { return view('admin.news.create'); }
    public function store(Request $r) {
        $data = $r->validate([
            'title'=>'required','content'=>'required',
            'status'=>'nullable|in:draft,published',
            'image'=>'nullable|image',
            'images.*' => 'image'
        ]);
        if($r->hasFile('image')) {
            $path = $r->file('image')->store('news','public');
            $data['image'] = '/storage/'.$path;
        }
    if(!isset($data['created_by'])){ $data['created_by'] = $r->user()?->id; }
    $news = News::create($data);
        if($r->hasFile('images')) {
            $i=0; foreach($r->file('images') as $img){
                $p = $img->store('news','public');
                $news->images()->create(['path'=>'/storage/'.$p,'position'=>$i++]);
            }
        }
        return redirect()->route('admin.news.index')->with('ok','Created');
    }
    public function edit(News $news) { return view('admin.news.edit', compact('news')); }
    public function update(Request $r, News $news) {
        $data = $r->validate([
            'title'=>'required','content'=>'required',
            'status'=>'nullable|in:draft,published',
            'image'=>'nullable|image','images.*'=>'image'
        ]);
        if($r->hasFile('image')) {
            $path = $r->file('image')->store('news','public');
            $data['image'] = '/storage/'.$path;
        }
    if(!isset($data['created_by'])){ $data['created_by'] = $r->user()?->id; }
    $news->update($data);
        if($r->hasFile('images')) {
            $startPos = $news->images()->count();
            foreach($r->file('images') as $idx=>$img){
                $p = $img->store('news','public');
                $news->images()->create(['path'=>'/storage/'.$p,'position'=>$startPos+$idx]);
            }
        }
        return redirect()->route('admin.news.index')->with('ok','Updated');
    }
    public function destroy(News $news) { $news->delete(); return back()->with('ok','Deleted'); }

    public function bulkDelete(Request $request){
        $ids = $request->input('ids',[]); if(!is_array($ids) || empty($ids)) return response()->json(['ok'=>false,'error'=>'No IDs'],422);
        News::whereIn('id',$ids)->delete(); return response()->json(['ok'=>true]);
    }
    public function export(Request $request){
        $q = News::query();
        if($ids = $request->query('ids')){ $a = array_filter(explode(',',$ids)); if($a) $q->whereIn('id',$a); }
        if($s = $request->query('search')) $q->where('title','like',"%$s%");
        $rows = $q->orderBy('id')->get(['id','title','created_at']);
        $callback = function() use ($rows){ $out=fopen('php://output','w'); fputcsv($out,['ID','Title','Created']); foreach($rows as $r){ fputcsv($out,[$r->id,$r->title,$r->created_at?->toDateTimeString()]); } fclose($out); };
        return response()->streamDownload($callback,'news.csv',['Content-Type'=>'text/csv']);
    }

    public function reorder(Request $request) {
        $data = $request->validate([
            'order'=>'required','order.*.id'=>'required|integer','order.*.position'=>'required|integer'
        ]);
        $map = collect($data['order']);
        // Update positions in bulk (loop; could optimize with CASE WHEN if needed later)
        foreach($map as $row){
            DB::table('news_images')->where('id',$row['id'])->update(['position'=>$row['position']]);
        }
        return response()->json(['ok'=>true]);
    }
}
