import 'package:flutter/material.dart';
import 'package:movie_watchlist/model/moviemodel.dart';
import 'package:movie_watchlist/services/dbhelper.dart';

class Addmoviescreen extends StatefulWidget {
  const Addmoviescreen({super.key});

  @override
  State<Addmoviescreen> createState() => _AddmoviescreenState();
}

class _AddmoviescreenState extends State<Addmoviescreen> {
  final _formkey = GlobalKey<FormState>();
  final _titlectrl = TextEditingController();
  final _categoryctrl = TextEditingController();
  final _posterctrl = TextEditingController();
  final _yearctrl = TextEditingController();
  final _notesctrl = TextEditingController();

  bool _watched = false;
  double _rating = 0;
  @override
  void dispose() {
    _titlectrl.dispose();
    _categoryctrl.dispose();
    _posterctrl.dispose();
    _yearctrl.dispose();
    _notesctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formkey.currentState!.validate()) return;
    final year = int.tryParse(_yearctrl.text.trim());
    final movie = Moviemodel(
      title: _titlectrl.text.trim(),
      category:
          _categoryctrl.text.trim().isEmpty
              ? 'Uncategorized'
              : _categoryctrl.text.trim(),
      poster: _posterctrl.text.trim(),
      year: year,
      watched: _watched,
      ratings: _rating,
      notes: _notesctrl.text.trim(),
    );
    await Dbhelper.instance.insertMovie(movie);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add movie'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: _titlectrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>(v == null || v.trim().isEmpty)?'Title is required':null, 
              ),
              const SizedBox(height: 12,),
              TextFormField(
                   controller: _categoryctrl,
                   decoration: InputDecoration(
                    labelText: 'Category(Action ,drama)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                   ),
              ),
              const SizedBox(height: 12,),  
              Row(
                children: [
                  Expanded(
                    child:TextFormField(
                      controller: _yearctrl,
                      keyboardType: TextInputType.number,
                      decoration:  InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                    ),
                     ),
                     const SizedBox(width: 12,),
                   Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Row(
                        children: [
                          const Text('Watched'),
                          const Spacer(),
                          Switch(
                            value: _watched,
                             onChanged: (v) => setState(() => _watched =v),
                             )
                        ],
                      ),
                    )
                    )
                ],
              ),
              const SizedBox(height: 12,),
              TextFormField(
                controller: _posterctrl,
                decoration: InputDecoration(
                  labelText: 'Poster url or file path',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
              ),
              const SizedBox(height: 12,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                        const Text('Rating'),
                        const SizedBox(width: 8,),
                        Text(_rating.toStringAsFixed(1))
                    ],
                  ),
                  Slider(
                    value:_rating ,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _rating.toStringAsFixed(1),
                   onChanged: (v)=>setState(() => _rating = v,)
                   ),
                   const SizedBox(height: 12,),
                   TextFormField(
                    controller: _notesctrl,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                      )
                    ),
                   ),
                   const SizedBox(height: 20,),
                   SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      onPressed: _save, 
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14)
                      ),
                      label: const Text('Save')
                      ),
                   )
                ],
              )
            ]
        ),
      ),
      )
      );
  }
}
