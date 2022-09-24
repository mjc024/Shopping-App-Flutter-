import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-Screen';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imgUrlController = TextEditingController();
  final _imgFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(description: '', id: '', imageUrl: '', price: 0, title: '');
  var _isInit = true;
  var _isload = false;
  var _isInitValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  @override
  void initState() {
    _imgFocusNode.addListener(_updateImageUrl);
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final prodId = ModalRoute.of(context)?.settings.arguments;
      if (prodId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .findById(prodId.toString());
        _isInitValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imgUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // _imgFocusNode.removeListener(_updateImageUrl);
    _descFocusNode.dispose();
    _priceFocusNode.dispose();
    _imgUrlController.dispose();
    _imgFocusNode.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imgFocusNode.hasFocus) {
      if ((!_imgUrlController.text.startsWith('http') &&
              !_imgUrlController.text.startsWith('https')) ||
          ((!_imgUrlController.text.endsWith('.jpg') &&
              !_imgUrlController.text.endsWith('jpeg') &&
              !_imgUrlController.text.endsWith('png')))) {
        return;
      }

      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isload = true;
    });

    if (_editedProduct.id != '') {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error Occured'),
                  content: Text('Something Went Wrong'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Okay'))
                  ],
                ));
      } 
      // finally {
      //   setState(() {
      //     _isload = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isload = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isload
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _isInitValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) => {
                        FocusScope.of(context).requestFocus(_priceFocusNode)
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            description: _editedProduct.description,
                            id: _editedProduct.id,
                            isFav: _editedProduct.isFav,
                            imageUrl: _editedProduct.imageUrl,
                            price: _editedProduct.price,
                            title: value.toString());
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter a value';
                        } else {
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                        initialValue: _isInitValues['price'],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (value) => {
                              FocusScope.of(context)
                                  .requestFocus(_descFocusNode)
                            },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter a number';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please Enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please Enter a num >0';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              description: _editedProduct.description,
                              id: _editedProduct.id,
                              isFav: _editedProduct.isFav,
                              imageUrl: _editedProduct.imageUrl,
                              price: double.parse(value.toString()),
                              title: _editedProduct.title);
                        }),
                    TextFormField(
                        initialValue: _isInitValues['description'],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Something about the product';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 chaacters long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              description: value.toString(),
                              id: _editedProduct.id,
                              isFav: _editedProduct.isFav,
                              imageUrl: _editedProduct.imageUrl,
                              price: _editedProduct.price,
                              title: _editedProduct.title);
                        }),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imgUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(_imgUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            // initialValue: _isInitValues['imageUrl'],
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imgUrlController,
                            focusNode: _imgFocusNode,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter a url for image';
                              }
                              if (!value.startsWith('http') ||
                                  !value.startsWith('https')) {
                                return 'Please Enter a valid URL for image';
                              }
                              if (!value.endsWith('.jpg') &&
                                  !value.endsWith('jpeg') &&
                                  !value.endsWith('png')) {
                                return 'Enter a valid URL for image';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                  description: _editedProduct.description,
                                  id: _editedProduct.id,
                                  isFav: _editedProduct.isFav,
                                  imageUrl: value.toString(),
                                  price: _editedProduct.price,
                                  title: _editedProduct.title);
                            },
                            onEditingComplete: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
