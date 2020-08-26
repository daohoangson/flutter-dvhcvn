import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;
import 'package:dvhcvn_demo/src/model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Demo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        child: ListView(
          children: [
            Level1(),
            Level2(),
            Level3(),
            Padding(
              child: Row(
                children: [
                  Expanded(child: ButtonReset()),
                  Expanded(child: ButtonDone()),
                ],
              ),
              padding: const EdgeInsets.all(8.0),
            )
          ],
        ),
        create: (_) => DemoData(),
      );
}

class ButtonReset extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FlatButton(
        child: Text('Reset'),
        onPressed: () => DemoData.of(context, listen: false).level1 = null,
      );
}

class ButtonDone extends StatelessWidget {
  @override
  Widget build(BuildContext context) => RaisedButton(
        child: Text('Done'),
        onPressed: () => showDialog(
            context: context,
            builder: (_) {
              final data = DemoData.of(context, listen: false);
              dvhcvn.Entity entity = data.level3;
              entity ??= data.level2;
              entity ??= data.level1;

              return Dialog(
                child: Padding(
                  child: Text(entity?.toString() ?? 'N/A'),
                  padding: const EdgeInsets.all(8.0),
                ),
              );
            }),
      );
}

class Level1 extends StatelessWidget {
  @override
  Widget build(BuildContext _) => Consumer<DemoData>(
        builder: (context, data, _) => ListTile(
          title: Text('Level 1'),
          subtitle: Text(data.level1?.name ?? 'Tap to select level 1.'),
          onTap: () => _select1(context, data),
        ),
      );

  void _select1(BuildContext context, DemoData data) async {
    final selected = await _select<dvhcvn.Level1>(context, dvhcvn.level1s);
    if (selected != null) data.level1 = selected;
  }
}

class Level2 extends StatefulWidget {
  @override
  _Level2State createState() => _Level2State();
}

class _Level2State extends State<Level2> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final data = DemoData.of(context);
    if (data.latestChange == 1) {
      // user has just selected a level 1 entity,
      // automatically trigger bottom sheet for quick level 2 selection
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _select2(context, data));
    }
  }

  @override
  Widget build(BuildContext _) => Consumer<DemoData>(
        builder: (context, data, _) => ListTile(
          title: Text('Level 2'),
          subtitle: Text(data.level2?.name ??
              (data.level1 != null
                  ? 'Tap to select level 2.'
                  : 'Select level 1 first.')),
          onTap: data.level1 != null ? () => _select2(context, data) : null,
        ),
      );

  void _select2(BuildContext context, DemoData data) async {
    final level1 = data.level1;
    if (level1 == null) return;

    final selected = await _select<dvhcvn.Level2>(
      context,
      level1.children,
      header: level1.name,
    );
    if (selected != null) data.level2 = selected;
  }
}

class Level3 extends StatefulWidget {
  @override
  _Level3State createState() => _Level3State();
}

class _Level3State extends State<Level3> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final data = DemoData.of(context);
    if (data.latestChange == 2) {
      // user has just selected a level 2 entity,
      // automatically trigger bottom sheet for quick level 3 selection
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _select3(context, data));
    }
  }

  @override
  Widget build(BuildContext _) => Consumer<DemoData>(
        builder: (context, data, _) => ListTile(
          title: Text('Level 3'),
          subtitle: Text(data.level3?.name ??
              (data.level2 != null
                  ? 'Tap to select level 3.'
                  : 'Select level 2 first.')),
          onTap: data.level2 != null ? () => _select3(context, data) : null,
        ),
      );

  void _select3(BuildContext context, DemoData data) async {
    final level2 = data.level2;
    if (level2 == null) return;

    final selected = await _select<dvhcvn.Level3>(
      context,
      level2.children,
      header: level2.name,
    );
    if (selected != null) data.level3 = selected;
  }
}

Future<T> _select<T extends dvhcvn.Entity>(
  BuildContext context,
  List<T> list, {
  String header,
}) =>
    showModalBottomSheet<T>(
      context: context,
      builder: (_) => Column(
        children: [
          // header (if provided)
          if (header != null)
            Padding(
              child: Text(
                header,
                style: Theme.of(context).textTheme.headline6,
              ),
              padding: const EdgeInsets.all(8.0),
            ),
          if (header != null) Divider(),

          // entities
          Expanded(
            child: ListView.builder(
              itemBuilder: (itemContext, i) {
                final item = list[i];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('#${item.id}, ${item.typeAsString}'),
                  onTap: () => Navigator.of(itemContext).pop(item),
                );
              },
              itemCount: list.length,
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
