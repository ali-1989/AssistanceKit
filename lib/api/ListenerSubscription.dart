
class ListenerSubscription {
	Function _source;
	bool _isCancel = false;
	
	ListenerSubscription(void Function(dynamic) fun) : _source = fun;

	Function get handler => _source;
	bool get isCancel => _isCancel;

	void onData(void Function(dynamic) fun) {
		_source = fun;
	}
	
	void cancel(){
		_isCancel = true;
	}
}