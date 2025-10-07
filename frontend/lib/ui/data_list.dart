import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'package:collection/collection.dart';
import '../theme/shad_theme.dart';

/// Generic responsive data list / table hybrid.
/// On wide screens: header row + columns; on narrow: stacked cards.
class DataList<T> extends StatefulWidget {
  final List<T> items;
  final List<DataListColumn<T>> columns; // at least 1
  final EdgeInsetsGeometry padding;
  final double breakpoint; // width at which we switch to table layout
  final Widget? empty;
  final bool sortableIndicators;
  final ValueChanged<T>? onTapRow;
  const DataList({super.key, required this.items, required this.columns, this.padding = const EdgeInsets.all(8), this.breakpoint = 760, this.empty, this.sortableIndicators=true, this.onTapRow});
  @override State<DataList<T>> createState()=> _DataListState<T>();
}

class _DataListState<T> extends State<DataList<T>> {
  int? _sortIndex; bool _asc = true;

  @override
  Widget build(BuildContext context){
    var data = widget.items;
    if(_sortIndex!=null){
      final col = widget.columns[_sortIndex!];
      final sorted = [...data];
      sorted.sort((a,b){
        final av = col.sortKey?.call(a) ?? '';
        final bv = col.sortKey?.call(b) ?? '';
        final res = compareAsciiLowerCase(av.toString(), bv.toString());
        return _asc? res : -res;
      });
      data = sorted;
    }
    final width = MediaQuery.of(context).size.width;
    final tableMode = width >= widget.breakpoint;
    if(data.isEmpty){
      return widget.empty ?? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Няма данни', style: Theme.of(context).textTheme.bodyMedium)));
    }
    if(!tableMode){
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (_, i){
          final item = data[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical:6),
            child: ShadCard(
              onTap: widget.onTapRow!=null? ()=> widget.onTapRow!(item) : null,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for(final col in widget.columns)
                    Padding(
                      padding: const EdgeInsets.only(bottom:6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          SizedBox(width: 120, child: Text(col.label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600))),
                          const SizedBox(width:8),
                          Expanded(child: col.cellBuilder(context, item)),
                        ],
                      ),
                    )
                ],
              ),
            ),
          );
        },
      );
    }
    // Table mode
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppTokens.space3, vertical: AppTokens.space2),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(.5)))
          ),
          child: Row(children:[
            for(int i=0;i<widget.columns.length;i++) ...[
              Expanded(
                flex: widget.columns[i].flex,
                child: GestureDetector(
                  onTap: widget.columns[i].sortable? (){ setState((){ if(_sortIndex==i){ _asc = !_asc; } else { _sortIndex=i; _asc=true; } }); } : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      Text(widget.columns[i].label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                      if(widget.columns[i].sortable && widget.sortableIndicators && _sortIndex==i) Padding(
                        padding: const EdgeInsets.only(left:4),
                        child: Icon(_asc? Icons.arrow_drop_up: Icons.arrow_drop_down, size:18),
                      )
                    ],
                  ),
                ),
              ),
              if(i != widget.columns.length-1) const SizedBox(width:12),
            ]
          ]),
        ),
        ...data.map((item){
          return InkWell(
            onTap: widget.onTapRow!=null? ()=> widget.onTapRow!(item) : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppTokens.space3, vertical: AppTokens.space3),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(.1)))
              ),
              child: Row(children:[
                for(int i=0;i<widget.columns.length;i++) ...[
                  Expanded(flex: widget.columns[i].flex, child: widget.columns[i].cellBuilder(context, item)),
                  if(i != widget.columns.length-1) const SizedBox(width:12),
                ]
              ]),
            ),
          );
        })
      ],
    );
  }
}

class DataListColumn<T> {
  final String label; final Widget Function(BuildContext,T) cellBuilder; final bool sortable; final dynamic Function(T)? sortKey; final int flex;
  DataListColumn({required this.label, required this.cellBuilder, this.sortable=false, this.sortKey, this.flex=1});
}
