@props(['rows'=>8,'cols'=>6])
<div class="table-skeleton">
  @for($i=0;$i<$rows;$i++)
    <div class="sk-row" style="grid-template-columns:repeat({{ $cols }},1fr)">
      @for($j=0;$j<$cols;$j++)<span class="sk-cell"></span>@endfor
    </div>
  @endfor
</div>