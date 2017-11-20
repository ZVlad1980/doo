var forEach = Array.prototype.forEach;


document.addEventListener('click', function(e) {
  var target = e.target;

  if (target.getAttribute('data-action')) {
    e.preventDefault();
    return action(target);
  }
});

function action(element) {
  var url = element.getAttribute('data-action');
  var meta = element.getAttribute('data-meta');
  var sync = element.getAttribute('data-sync');

  var params = {
    path: window.location.hash,
    meta: meta
  };

  if (sync !== null && sync !== undefined) {
    params.inputs = serialize(document);
  }

  xhr.post(url, params, refresh);
}

function refresh(err, response) {
  if (err) return console.error(err);

  var location = window.location;
  var locationChanged = location.hash !== response.path;

  var regions = response.regions;

  for (var id in regions) {
    var element = document.getElementById(name);
    var scrollTop = locationChanged ? 0 : element.scrollTop;

    element.innerHTML = regions[id];
    element.scrollTop = scrollTop;
  }
}

function serialize(root) {
  var inputs = root.querySelectorAll('input');
  var values = {};

  forEach.call(inputs, function(input) {
    var name = input.name;

    if (!name) return;

    var type = input.type;
    var value = input.value;

    if (type === 'checkbox' || type === 'radio')
      value = input.checked && value;

    if (value) values[name] = value;
  });

  return values;
}


var xhr = {};

xhr.post = function(url, params, callback) {
  var xhr = new XMLHttpRequest();

  xhr.open('POST', url, true);
  xhr.setRequestHeader('Content-Type', 'application/json');

  xhr.onerror = function() {
    callback(new HttpError(xhr.status || 0, 'Connection Error'));
  };

  xhr.onload = function() {
    var status = xhr.status;
    var response = xhr.responseText;

    if (status < 200 || xhr.status > 400)
      return callback(new HttpError(status, response));

    callback(undefined, response);
  };


  xhr.send(params);
};
