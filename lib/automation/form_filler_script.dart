import 'dart:convert';

class FormFillerScript {
  /// Builds a JavaScript payload to populate approved fields only
  static String buildFillScript(List<Map<String, String>> fillInstructions) {
    final instructionsJson = jsonEncode(fillInstructions);

    return '''
(function() {
  try {
    const instructions = $instructionsJson;
    let filledCount = 0;
    
    // Helper to trigger React / Vue / Angular change detection
    function setNativeValue(element, value) {
      const valueSetter = Object.getOwnPropertyDescriptor(element, 'value')?.set;
      const prototype = Object.getPrototypeOf(element);
      const prototypeValueSetter = Object.getOwnPropertyDescriptor(prototype, 'value')?.set;
      
      if (prototypeValueSetter && valueSetter !== prototypeValueSetter) {
        prototypeValueSetter.call(element, value);
      } else if (valueSetter) {
        valueSetter.call(element, value);
      } else {
        element.value = value;
      }
    }

    instructions.forEach(function(item) {
      if (!item.selector || item.value === undefined) return;
      
      const el = document.querySelector(item.selector);
      if (el) {
        el.focus();
        
        if (el.tagName.toUpperCase() === 'SELECT') {
          // Select matching option or closest match
          let matched = false;
          for (let i = 0; i < el.options.length; i++) {
            if (el.options[i].text.toLowerCase().includes(item.value.toLowerCase()) ||
                el.options[i].value.toLowerCase() === item.value.toLowerCase()) {
              el.selectedIndex = i;
              matched = true;
              break;
            }
          }
          if (!matched && el.options.length > 0) {
            el.value = item.value;
          }
        } else {
          setNativeValue(el, item.value);
        }

        // Dispatch full lifecycle events
        el.dispatchEvent(new Event('input', { bubbles: true, cancelable: true }));
        el.dispatchEvent(new Event('change', { bubbles: true, cancelable: true }));
        el.dispatchEvent(new Event('blur', { bubbles: true, cancelable: true }));
        
        // Highlight briefly for clear user feedback
        el.style.transition = 'box-shadow 0.3s ease, outline 0.3s ease';
        el.style.outline = '2px solid #10B981';
        el.style.boxShadow = '0 0 8px rgba(16, 185, 129, 0.4)';
        
        setTimeout(function() {
          el.style.outline = '';
          el.style.boxShadow = '';
        }, 3000);

        filledCount++;
      }
    });

    return JSON.stringify({
      success: true,
      filledCount: filledCount,
      totalRequested: instructions.length
    });
  } catch (err) {
    return JSON.stringify({
      success: false,
      error: err.toString(),
      filledCount: 0
    });
  }
})();
''';
  }
}
