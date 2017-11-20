(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
/**
 * Module dependencies.
 */
var callback = require('../callback');

/**
 * Request callback registered in data-action attribute.
 *
 * Options available through data attributes:
 *   `data-action` {Number} callback id
 *   `data-sync` {Boolean} synchronize form controls
 *   `data-meta` {*} additional information passed to callback
 *
 * @param {MouseEvent} e
 *
 * @api private
 */
module.exports = function(e) {
  var target = e.target;
  var action = target.getAttribute('data-action');

  if (!action) return;

  e.preventDefault();

  callback(action, {
    sync: target.getAttribute('data-sync'),
    meta: target.getAttribute('data-meta')
  });
};

},{"../callback":6}],2:[function(require,module,exports){
/**
 * Module dependencies.
 */
var render = require('../render');
var request = require('../request');


/**
 * Use request and pushState for internal links.
 *
 * @param {MouseEvent} e
 *
 * @api private
 */
module.exports = function(e) {
  var target = e.target;
  var href = target.getAttribute('href');

  if (!href) return;

  var location = window.location;
  var root = location.protocol + "//" + location.host;

  if (!(href[0] === '/' || href.slice(0, root.length) === root)) return;

  e.preventDefault();

  request.post(href, render);
};

},{"../render":9,"../request":10}],3:[function(require,module,exports){
/**
 * Module contains collection of all behaviors
 */
exports.anchor = require('./anchor');
exports.action = require('./action');
exports.suggest = require('./suggest');

},{"./action":1,"./anchor":2,"./suggest":5}],4:[function(require,module,exports){
/**
 * Module dependencies.
 */
var helpers = require('../helpers');
var callback = require('../callback');

/**
 * Shortcuts.
 */
var extend = helpers.extend;
var addClass = helpers.addClass;
var fireEvent = helpers.fireEvent;
var removeClass = helpers.removeClass;

var CHUNK = 50;
var FETCH_AT = 20;
var SELECTED_CSS = 'selected';

/**
 * Initialize list with infinity scroll using given element as container
 * if attribute `data-behavior` equals `list`.
 *
 * Attribute `data-source` must contain an id of the data source callback.
 *
 * Data source callback will receive following meta param:
 *
 *   { q: 'Search query', from: 0, to: 50 }
 *
 * and must render plain html with list of the elements to display.
 * Each element must have unique `data-id` attribute.
 *
 * @param {DOMElement} element
 *
 * @return {Object} list controls
 *
 * @api public
 */
module.exports = function(element) {
  var behavior = element.getAttribute('data-behavior');

  if (behavior !== 'list') return;

  return list(element);
};

/**
 * List initialization function
 *
 * @param {DOMElement} element
 *
 * @return {Object} list controls
 *
 * @api private
 */
function list(element) {
  var source = element.getAttribute('data-source');
  var thresholds = {};
  var lastScroll = 0;
  var lastQuery = {};
  var offset = 0;
  var selectedId;
  var selected;
  var request;

  updateThreshold();

  element.addEventListener('click', onClick);
  element.addEventListener('scroll', onScroll);
  element.addEventListener('keydown', onKeyDown);

  var keyEvents = {
    27: null,         // ESC
    40: nextItem,     // UP
    38: previousItem  // DOWN
  };

  return {
    replace: replace,
    onKeyDown: onKeyDown,
    getSelected: getSelected
  };

  /**
   * Replace list fetching query and reload all items.
   * Query result will be returned in callback.
   *
   * @param {String} q
   * @param {Function} callback
   *
   * @api public
   */
  function replace(q, callback) {
    var query = { q: q, from: 0, to: CHUNK };

    invoke(query, function(err, data) {
      if (err) return callback(err);

      element.innerHTML = data;
      offset = 0;

      callback(null, data);

      select();
      updateThreshold();
    });
  }

  /**
   * Fetch `CHUNK` more items and prepend them to the top of the list.
   *
   * @api private
   */
  function prepend() {
    var query = extend({}, lastQuery);

    query.to = offset;
    query.from = query.to - CHUNK - 1;

    if (query.from < 0) query.from = 0;

    invoke(query, function(err, response) {
      if (err) return console.error(err);
      if (!response) return;

      var count = element.children.length;
      var height = element.scrollHeight;

      element.insertAdjacentHTML('afterBegin', response);
      updateThreshold('bottom');

      offset -= element.children.length - count;

      setScroll(element.scrollTop + element.scrollHeight - height);

      slice('bottom');
    });
  }

  /**
   * Fetch `CHUNK` more items and append them to the bottom of the list.
   *
   * @api private
   */
  function append() {
    var query = extend({}, lastQuery);

    query.from = offset + element.children.length;
    query.to = query.from + CHUNK;

    invoke(query, function(err, response) {
      if (err) return console.error(err);
      if (!response) return;

      element.insertAdjacentHTML('beforeEnd', response);
      updateThreshold('bottom');

      slice('top');
    });
  }

  /**
   * Update threshold for direction.
   *
   * If direction is empty updates threshold in both directions.
   *
   * @param {String} direction (`top` or `bottom`)
   *
   * @api private
   */
  function updateThreshold(direction) {
    if (!direction || direction === 'top')
      thresholds.top = threshold('top');

    if (!direction || direction === 'bottom')
      thresholds.bottom = threshold('bottom');
  }

  /**
   * Calculate threshold for direction.
   *
   * Sums heights of `FETCH_AT` number of elements.
   *
   * @param {String} direction (`top` or `bottom`)
   *
   * @return {Number} height
   *
   * @api private
   */
  function threshold(direction) {
    var items = Array.prototype.slice.call(element.children);
    var height = 0;

    items = direction === 'top' ?
      items.slice(0, FETCH_AT) : items.slice(-FETCH_AT);

    for (var i=0, len=items.length; i<len; i++)
      height += items[i].offsetHeight;

    return height;
  }

  /**
   * Remove all invisible elements in direction
   * up to twice of threshold value.
   *
   * @param {String} direction (`top` or `bottom`)
   *
   * @api private
   */
  function slice(direction) {
    var items = Array.prototype.slice.call(element.children);

    if (direction === 'bottom') items.reverse();

    var minScroll = thresholds[direction] * 2;
    var scroll = element.scrollTop;
    var idx = 0;

    if (direction === 'bottom') scroll = element.scrollHeight - scroll;

    while (scroll > minScroll && idx < items.length) {
      var item = items[idx++];
      scroll -= item.offsetHeight;

      element.removeChild(item);
    }

    if (direction === 'top') {
      offset += idx;
      setScroll(scroll);
    }

    updateThreshold(direction);
  }

  /**
   * Invoke data source callback with query.
   *
   * Received data will be available in callback.
   *
   * @param {Object} query
   * @param {Function} next
   *
   * @api private
   */
  function invoke(query, next) {
    cancel();

    if (isEqual(query, lastQuery)) return next();

    request = callback(source, { sync: true, meta: query }, done);

    function done(err, response) {
      if (err) return next(err);

      lastQuery = query;
      request = null;

      next(null, response);

      if (selectedId) selectId(selectedId);
    }
  }

  /**
   * Abort current data request.
   *
   * @api private
   */
  function cancel() {
    if (!request) return;

    request.abort();

    request = null;
  }

  /**
   * Set item as selected.
   *
   * `SELECTED_CSS` class will be added to the selected item, list container
   * scroll will be shifted to selection.
   *
   * Triggers `change` event on container element if selection was changed.
   *
   * @param {DOMElement} item
   *
   * @api private
   */
  function select(item) {
    var itemId = item && item.getAttribute('data-id');

    if (selected) removeClass(selected, SELECTED_CSS);
    if (item) addClass(item, SELECTED_CSS);

    if (selectedId === itemId) return;

    selected = item;
    selectedId = itemId;

    scrollTo(item);

    fireEvent(element, 'change');
  }

  /**
   * Set item with given `data-id` value as selected.
   *
   * @param {Number} id
   *
   * @api private
   */
  function selectId(id) {
    if (!id) return select();

    var item = element.querySelector('[data-id="' + id + '"]');

    if (item) select(item);
  }

  /**
   * Selected item getter.
   *
   * @return {DOMElement}
   *
   * @api public
   */
  function getSelected() {
    return selected;
  }

  /**
   * Return item at offset from currently selected item.
   * If there is no selected item returns first one.
   *
   * @param {Number} offset
   *
   * @return {DOMElement}
   *
   * @api private
   */
  function itemAtOffset(offset) {
    var items = Array.prototype.slice.call(element.children);
    var index = items.indexOf(selected) + offset;

    if (index >= items.length) index = items.length - 1;
    else if (index < 0) index = 0;

    return items[index];
  }

  /**
   * Return next item from selected.
   *
   * @return {DOMElement}
   *
   * @api private
   */
  function nextItem() {
    return itemAtOffset(1);
  }

  /**
   * Return previous item from selected.
   *
   * @return {DOMElement}
   *
   * @api private
   */
  function previousItem() {
    return itemAtOffset(-1);
  }

  /**
   * Keyboard event handler.
   *
   * Change selection in given direction.
   *
   * @param {Event} e
   *
   * @api public
   */
  function onKeyDown(e) {
    var code = e.keyCode;

    if (!(code in keyEvents)) return;

    var item = keyEvents[code];

    select(item && item());
    e.stopImmediatePropagation();
  }

  /**
   * List element click event handler.
   *
   * Set event target element as selected if `data-id`
   * attribute is defined on it.
   *
   * @param {Event} e
   *
   * @api private
   */
  function onClick(e) {
    var item = e.target;

    if (item.getAttribute('data-id')) select(item);
  }

  /**
   * Set list container scrollTop to given value.
   *
   * @param {Number} scroll
   *
   * @api private
   */
  function setScroll(scroll) {
    element.scrollTop = scroll;
  }

  /**
   * Scroll event handler.
   *
   * Invokes `append` or `prepend` functions when needed.
   *
   * @api private
   */
  function onScroll() {
    if (request) return;

    var scroll = element.scrollTop;
    var height = element.scrollHeight - element.offsetHeight;
    var isDown = (scroll - lastScroll) > 0;

    if (isDown && ((height - scroll) < thresholds.bottom))
      append();
    else if (!isDown && (scroll < thresholds.top))
      prepend();

    lastScroll = scroll;
  }

  /**
   * Shift list container scroll to item.
   *
   * @param {DOMElement} item
   *
   * @api private
   */
  function scrollTo(item) {
    if (!item) return setScroll(0);

    var eTop = element.scrollTop;
    var eBottom = eTop + element.clientHeight;
    var iTop = item.offsetTop;
    var iBottom = iTop + item.offsetHeight;

    if (iBottom > eBottom)
      setScroll(element.scrollTop + iBottom - eBottom);
    else if (iTop < eTop)
      setScroll(element.scrollTop - Math.max(eTop - iTop , 0));
  }
}

/**
 * Compare two list query objects.
 *
 * @param {Object} a
 * @param {Object} b
 *
 * @return {Boolean}
 *
 * @api private
 */
function isEqual(a, b) {
  var aq = a.q || {};
  var bq = b.q || {};

  if (((typeof(aq) === 'string') || (typeof(bq) === 'string')) && aq !== bq)
    return false;

  for (var key in aq) if (aq[key] !== bq[key]) return false;

  return a.from === b.from && a.to === b.to;
}

},{"../callback":6,"../helpers":7}],5:[function(require,module,exports){
var list = require('./list');
var action = require('./action');
var helpers = require('../helpers');

var fireEvent = helpers.fireEvent;

var DELAY = 100;

/**
 * Initialize field with suggestions on text input.
 *
 * Input attribute `data-behavior` value must equal `suggest`.
 *
 * Target input will be used to display selected item description and must
 * have following siblings for suggestions list and storing selected
 * item identifier:
 *
 *   <input name="company.name" data-behavior="suggest"/>
 *   <input name="company.id" type="hidden"/>
 *   <div class="flyout">
 *     <ul class="modal" data-behavior="list" data-source="companies">
 *     </ul>
 *   </div>
 *
 * Suggest input will pass keyboard events to suggestions list for navigation.
 *
 * @api public
 */
module.exports = function(e) {
  var target = e.target;
  var behavior = target.getAttribute('data-behavior');

  if (behavior !== 'suggest') return;

  suggest(target, e);

  target.removeAttribute('data-behavior');
};

/**
 * Suggest input initializer.
 *
 * @param {DOMElement} input
 *
 * @api private
 */
function suggest(input) {
  var hiddenId = input.nextElementSibling;
  var flyout = hiddenId.nextElementSibling;
  var suggestions = list(flyout.children[0]);
  var lastValue = input.value;
  var selectedValue;
  var selectedId;
  var timer;
  var skip;

  if (!suggestions) throw new Error('Unable to initialize suggestions list');

  var keyEvents = {
    9: setSkip(false),  // TAB
    13: handleSelection // ENTER
  };

  input.addEventListener('focus', focusIn);
  input.addEventListener('blur', focusOut);
  input.addEventListener('keyup', onKeyUp);
  input.addEventListener('keydown', sendToList);
  input.addEventListener('keydown', onKeyDown);

  // make action on change selection
  hiddenId.addEventListener('act', action);

  // TODO: initialize sync behavior on hidden `id` input if needed

  flyout.addEventListener('mouseenter', setSkip(true));
  flyout.addEventListener('mouseleave', setSkip(false));
  flyout.addEventListener('click', handleSelection);

  focusIn();

  /**
   * Update selected value and blur from input if event is passed.
   *
   * @param {Event} e
   *
   * @api private
   */
  function handleSelection(e) {
    var item = suggestions.getSelected();

    selectedId = item && item.getAttribute('data-id');
    selectedValue = item && item.getAttribute('data-value') ||
      item.textContent;

    if (e) blur();
  }

  /**
   * FocusIn event handler.
   *
   * Invokes empty query and show list with all available suggestions.
   *
   * @api private
   */
  function focusIn() {
    selectedId = hiddenId.value;
    selectedValue = input.value;

    query('');
  }

  /**
   * FocusOut event handler.
   *
   * Invokes `blur` function if mouse is not over
   * the suggestions list or if `TAB` key is pressed.
   *
   * @api private
   */
  function focusOut() {
    if (skip) return;

    blur();
  }

  /**
   * KeyUp event handler.
   *
   * Invokes query for suggestions if input value was changed.
   *
   * @param {Event} e
   *
   * @api
   */
  function onKeyUp(e) {
    var value = input.value;
    var code = e.keyCode;

    if (!value) selectedId = selectedValue = null;

    if (lastValue === value) return;

    lastValue = value;
    scheduleQuery(value);
  }

  /**
   * Send keyboard events to suggestions list if it is visible.
   *
   * @param {Event} e
   *
   * @api private
   */
  function sendToList(e) {
    if (flyout.style.display === 'none') return;

    suggestions.onKeyDown(e);
  }

  /**
   * Keyboard events handler.
   *
   * @param {Event} e
   *
   * @api private
   */
  function onKeyDown(e) {
    var handler = keyEvents[e.keyCode];

    if (handler) return handler(e);
  }

  /**
   * Perform `focusOut` actions:
   *
   *   * hide suggestions list
   *   * cancel query invokation
   *   * trigger `change` event if needed
   *
   * @api private
   */
  function blur() {
    var currentId = hiddenId.value;

    hiddenId.value = selectedId || '';
    input.value = selectedValue || '';

    flyout.style.display = 'none';

    cancelQuery();

    if (currentId === selectedId) return;

    fireEvent(hiddenId, 'act');
  }

  /**
   * Schedule query string for invokation in `DELAY` milliseconds.
   *
   * @param {String} q
   *
   * @api private
   */
  function scheduleQuery(q) {
    cancelQuery();

    timer = setTimeout(function() {
      timer = null;
      query(q);
    }, DELAY);
  }

  /**
   * Cancel query delay timeout
   *
   * @api private
   */
  function cancelQuery() {
    if (!timer) return;

    clearTimeout(timer);
    timer = null;
  }

  /**
   * Replace suggestions with query.
   *
   * Will show suggestions list if query result was not empty.
   *
   * @param {String} q
   *
   * @api private
   */
  function query(q) {
    suggestions.replace(q, function(err, data) {
      if (err) return console.error(err);

      lastQuery = q;

      flyout.style.display = (data && data.length) ? 'block' : 'none';
    });
  }

  /**
   * `skip` variable setter generator
   *
   * @param {Boolean} value
   *
   * @return {Function} setter
   *
   * @api private
   */
  function setSkip(value) {
    return (function() {
      skip = value;
    });
  }
}

},{"../helpers":7,"./action":1,"./list":4}],6:[function(require,module,exports){
/**
 * Module dependencies.
 */
var render = require('./render');
var request = require('./request');

/**
 * Shortcuts.
 */
var forEach = Array.prototype.forEach;


module.exports = callback;


/**
 * Make XHR request to callback id and update regions content.
 *
 * Examples:
 *   callback(1)                            // Invoke callback with id = 1
 *   callback(1, { sync: true })            // and synchronize inputs
 *   callback(1, { meta: { object: 12 } })  // or pass additional metadata
 *   callback(1, { sync: true }, next)      // or process response manually
 *
 * @param {Number} id
 * @param {Object|Function} options or next
 * @param {Function} next
 *
 * @return {XMLHttpRequest}
 *
 * @api public
 */
function callback(id, options, next) {
  if (typeof options === 'function') next = options, options = null;
  if (!options) options = {};

  var url = window.location.pathname + '?callback=' + id;

  var params = { path: url };

  if (options.meta) params.meta = options.meta;
  if (options.sync) params.inputs = serialize(document);

  return request.post(url, params, next || render);
}

/**
 * Return form controls values as object
 *
 * @param {DOMElement} root
 *
 * @return {Object}
 *
 * @api private
 */
function serialize(root) {
  root = root || document;

  // TODO: Add textarea to selectors
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

},{"./render":9,"./request":10}],7:[function(require,module,exports){
exports.extend = extend;
exports.addClass = addClass;
exports.fireEvent = fireEvent;
exports.removeClass = removeClass;

/**
 * Merge contents of passed objects into first object
 *
 * @param (Object) out...
 *
 * @return (Object) object
 *
 * @api public
 */
function extend(out) {
  out = out || {};

  for (var i=1; i<arguments.length; i++) {
    var obj = arguments[i];

    if (!obj) continue;

    for (var key in obj) {
      if (!obj.hasOwnProperty(key)) continue;

      if (typeof obj[key] === 'object')
        extend(out[key], obj[key]);
      else
        out[key] = obj[key];
    }
  }

  return out;
}

/**
 * Remove space-separated classes list from DOM element
 *
 * @param {DOMElement} element
 * @param {String} classes
 *
 * @api public
 */
function removeClass(element, classes) {
  if (element.classList) return element.classList.remove(classes);

  var regexp = new RegExp('(^|\\b)' + classes.split(' ').join('|') +
    '(\\b|$)', 'gi');

  element.className = element.className.replace(regexp, ' ');
}

/**
 * Add space-separated classes list to DOM element
 *
 * @param {DOMElement} element
 * @param {String} classes
 *
 * @api public
 */
function addClass(element, classes) {
  if (element.classList) return element.classList.add(classes);

  element.className += ' ' + classes;
}

/**
 * Universal code for event fireing
 *
 * @param {DOMElement} element
 * @param {String} event name
 *
 * @api public
 */
function fireEvent(element, name) {
  var event = document.createEvent('HTMLEvents');

  event.initEvent(name, true, false);
  element.dispatchEvent(event);
}

},{}],8:[function(require,module,exports){
/**
 * Module dependencies.
 */
var state = require('./state');
var behaviors = require('./behaviors');


/**
 * Attach behaviors to event listeners
 */
document.addEventListener('click', behaviors.action);
document.addEventListener('click', behaviors.anchor);
document.addEventListener('change', behaviors.action);
document.addEventListener('focusin', behaviors.suggest);

/**
 * Listen history event
 */
window.addEventListener('popstate', state.pop);

},{"./behaviors":3,"./state":11}],9:[function(require,module,exports){
module.exports = render;

/**
 * Callback function used to update URL and regions content
 *
 * Response should contain path and regions.
 *
 * @param {Error} err
 * @param {Object} response
 *
 * @api private
 */
function render(err, response) {
  if (err) return console.error(err);

  response = JSON.parse(response);

  var path = response.path;
  var active = document.activeElement &&
    document.activeElement.getAttribute('id');
  var locationChanged = path !== window.location.pathname;

  if (locationChanged)
    window.history.pushState({}, response.title, path);

  var regions = response.regions;

  for (var name in regions) {
    var element = document.getElementById(name);
    var scrollTop = locationChanged ? 0 : element.scrollTop;

    element.innerHTML = regions[name];
    element.scrollTop = scrollTop;
  }

  if (active) active = document.getElementById(active);
  if (active) active.focus();
}

},{}],10:[function(require,module,exports){
exports.post = post;


/**
 * Shortcut wrapper to perform AJAX requests.
 *
 * Creates, sends and returns browser standart XMLHttpRequest.
 * Server response is expected to be in JSON format.
 *
 * @param {String} url
 * @param {Object|Function} params or callback
 * @param {Function} callback
 *
 * @return {XMLHttpRequest}
 *
 * @api private
 */
function post(url, params, callback) {
  if (!callback) callback = params, params = null;

  var xhr = new XMLHttpRequest();

  xhr.open('POST', url, true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

  xhr.onerror = function() {
    callback(new HttpError(xhr.status || 0, 'Connection Error'));
  };

  xhr.onload = function() {
    var status = xhr.status;
    var response = xhr.responseText;

    if (status < 200 || status > 400)
      return callback(new HttpError(status, response));

    callback(null, response);
  };

  xhr.send(params && JSON.stringify(params));

  return xhr;
}

},{}],11:[function(require,module,exports){
/**
 * Module dependencies
 */
var render = require('./render');
var request = require('./request');

/**
 * Exports
 */
exports.pop = pop;


var popped = ('state' in window.history && window.history.state !== null);
var initialURL = window.location.href;


/**
 * Popstate event listener.
 *
 * Request and render layout regions for current location.
 */
function pop() {
  // Ignore inital popstate that some browsers fire on page load
  var initialPop = !popped && window.location.href === initialURL;

  if (initialPop) popped = true;
  else request.post(window.location.pathname, render);
}

},{"./render":9,"./request":10}]},{},[8]);
