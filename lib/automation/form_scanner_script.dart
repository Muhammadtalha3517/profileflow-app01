class FormScannerScript {
  /// JavaScript script to be evaluated inside WebView.
  /// Collects visible form fields and their metadata, returning a JSON array string.
  static const String jsScanScript = r'''
(function() {
  try {
    const fields = [];
    const elements = document.querySelectorAll('input:not([type="hidden"]):not([type="submit"]):not([type="button"]):not([type="image"]):not([type="file"]), textarea, select');
    
    let index = 0;
    elements.forEach(function(el) {
      // Check visibility
      const style = window.getComputedStyle(el);
      if (style.display === 'none' || style.visibility === 'hidden' || style.opacity === '0' || el.offsetParent === null) {
        return;
      }
      
      const tag = el.tagName.toUpperCase();
      const type = (el.getAttribute('type') || 'text').toLowerCase();
      const name = el.getAttribute('name') || '';
      const id = el.getAttribute('id') || ('pf_field_' + index);
      const placeholder = el.getAttribute('placeholder') || '';
      const autocomplete = el.getAttribute('autocomplete') || '';
      const ariaLabel = el.getAttribute('aria-label') || el.getAttribute('aria-description') || '';
      
      // Try to find explicit associated label
      let labelText = '';
      if (el.id) {
        const lbl = document.querySelector('label[for="' + el.id + '"]');
        if (lbl) labelText = lbl.innerText.trim();
      }
      
      // Try closest parent label
      if (!labelText) {
        const parentLabel = el.closest('label');
        if (parentLabel) {
          labelText = parentLabel.innerText.replace(el.value || '', '').trim();
        }
      }
      
      // Try preceding sibling or parent container text
      let surroundingText = '';
      if (!labelText) {
        const parent = el.parentElement;
        if (parent) {
          surroundingText = (parent.innerText || '').substring(0, 100).trim();
        }
      }
      
      // Assign synthetic id if none exists for reliable targeting
      if (!el.id) {
        el.setAttribute('data-pf-id', 'pf_el_' + index);
      }
      
      const uniqueSelector = el.id 
        ? '#' + CSS.escape(el.id) 
        : '[data-pf-id="pf_el_' + index + '"]';

      fields.push({
        elementId: id,
        name: name,
        type: type,
        tagName: tag,
        placeholder: placeholder,
        label: labelText,
        ariaLabel: ariaLabel,
        autocomplete: autocomplete,
        surroundingText: surroundingText,
        selector: uniqueSelector
      });
      
      index++;
    });
    
    return JSON.stringify({
      success: true,
      fieldsCount: fields.length,
      fields: fields,
      hasCaptcha: /captcha|recaptcha|hcaptcha/i.test(document.body.innerText),
      pageTitle: document.title || window.location.href,
      url: window.location.href
    });
  } catch (err) {
    return JSON.stringify({
      success: false,
      error: err.toString(),
      fields: []
    });
  }
})();
''';
}
