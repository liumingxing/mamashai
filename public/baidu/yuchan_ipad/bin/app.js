;//server side config
var socketPort = 
    (typeof process !== 'undefined' && 
     typeof process.BAE !== 'undefined') ?
    80 : 8082;
var clientSocketServer = typeof location !== 'undefined' ? 
        location.hostname + ':' + socketPort + '/socket/' : '';

clientSocketServer = clientSocketServer.replace('.duapp.com', '.sx.duapp.com'); 

sumeru.config({
	httpServerPort: 8080,
	sumeruPath: '/../sumeru',
	soketPort: socketPort,
	clientSocketServer : clientSocketServer
});
;sumeru.router.add(

	{
		pattern: '/itworks',
		action: 'App.itworks'
	}

);

//sumeru.router.setDefault('App.itworks');


App.itworks = sumeru.controller.create(function(env, session){

	env.onrender = function(doRender){
		doRender("itworks", ['push','left']);
	};

});