var URL = window.URL || window.webkitURL || window.mozURL || window.msURL;
navigator.saveBlob = navigator.saveBlob || navigator.msSaveBlob || navigator.mozSaveBlob || navigator.webkitSaveBlob;
window.saveAs = window.saveAs || window.webkitSaveAs || window.mozSaveAs || window.msSaveAs;

// Because highlight.js is a bit awkward at times
var languageOverrides = {
    js: 'javascript',
    html: 'xml'
};

var livestyles;

emojify.setConfig({
    img_dir: 'emoji'
});

var md = markdownit({
        html: true,
        highlight: function(code, lang) {
            if (languageOverrides[lang]) lang = languageOverrides[lang];
            if (lang && hljs.getLanguage(lang)) {
                try {
                    return hljs.highlight(lang, code).value;
                } catch (e) {}
            }
            return '';
        }
    })

//md.use(markdownitFootnote)
md.use(markdownItAnchor)
md.use(markdownitTaskLists)
//md.use(markdownItSourceMap)

var hashto;

function update(e) {
    setOutput(e.getValue());

    //If a title is added to the document it will be the new document.title, otherwise use default
    var headerElements = document.querySelectorAll('h1');
    if (headerElements.length > 0 && headerElements[0].textContent.length > 0) {
        title = headerElements[0].textContent;
    } else {
        title = 'Markdown Editor'
    }

    //To avoid too much title changing we check if is not the same as before
    oldTitle = document.title;
    if (oldTitle != title) {
        oldTitle = title;
        document.title = title;
    }
    //clearTimeout(hashto);
    //hashto = setTimeout(updateHash, 1000);
}

function setOutput(val) {
    val = val.replace(/<equation>((.*?\n)*?.*?)<\/equation>/ig, function(a, b) {
        return '<img src="http://latex.codecogs.com/png.latex?' + encodeURIComponent(b) + '" />';
    });

    var out = document.getElementById('out');
    var old = out.cloneNode(true);
    out.innerHTML = md.render(val);
    emojify.run(out);
    console.log(out.innerHTML);
    // Checks if there are any task-list present in out.innerHTML
//    out.innerHTML = render_tasklist(out.innerHTML);

    var allold = old.getElementsByTagName("*");
    if (allold === undefined) return;

    var allnew = out.getElementsByTagName("*");
    if (allnew === undefined) return;

    for (var i = 0, max = Math.min(allold.length, allnew.length); i < max; i++) {
        if (!allold[i].isEqualNode(allnew[i])) {
            out.scrollTop = allnew[i].offsetTop;
//            return;
        }
    }
}


//CodeMirrorSpellChecker({
//    codeMirrorInstance: CodeMirror,
//});

var editor = CodeMirror.fromTextArea(document.getElementById('code'), {
//    mode: "spell-checker",
    mode: {name: "gfm"},
    lineNumbers: false,
    matchBrackets: true,
    lineWrapping: true,
    indentWithTabs: false,
    indentUnit: 4,
    theme: 'default',
    extraKeys: {
        "Enter": "newlineAndIndentContinueMarkdownList",
        "Tab": (cm) => cm.execCommand("indentMore"),
        "Shift-Tab": (cm) => cm.execCommand("indentLess")
    }
});

editor.on('change', update);

let emojis = {
    "done": ["heavy_check_mark", "emoji/heavy_check_mark.png"],
    "inprogress": ["hourglass_flowing_sand", "emoji/hourglass_flowing_sand.png"],
}
let emojiList = []
for (let key in emojis) {
    emojiList.push({
        key: `${key}`,
        text: `${emojis[key][0]}:`,
        render: (element) => {
            element.innerHTML = `<img width="15" height="15" src="${emojis[key][1]}" alt="icon" async></img> ${key}`
        }
    })
}

let emojiComplete = function(cm) {
    CodeMirror.showHint(cm, function() {
        let cur = cm.getCursor(), token = cm.getTokenAt(cur)
        let start = token.start, end = cur.ch, word = token.string.slice(0, end - start)
        let ch = cur.ch, line = cur.line
        let currentWord = token.string
        while (ch-- > -1) {
            let t = cm.getTokenAt({ch, line}).string
            if (t === ':') {
                let filteredList = emojiList.filter((item) => {
                    return item.key.indexOf(currentWord) == 0 ? true : false
                })
                if (filteredList.length >= 1) {
                    return {
                    list: filteredList,
                        from: CodeMirror.Pos(line, ch),
                    to: CodeMirror.Pos(line, end)
                    }
                }
            }
            currentWord = t + currentWord
        }
    }, { completeSingle: false })
}

editor.on('change', emojiComplete)

//editor.on("scroll" , function(e){
//    // https://tokunagakazuya.tk/eokn
//    var scrollInfo = e.getScrollInfo();
//
//    // get line number of the top line in the page
//    var lineNumber = e.lineAtHeight(scrollInfo.top, 'local');
//    // get the text content from the start to the target line
//    var range = e.getRange({line: 0, ch: null}, {line: lineNumber, ch: null});
//    var parser = new DOMParser();
//    var doc = parser.parseFromString(marked(range), 'text/html');
//    var totalLines = doc.body.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li, pre, blockquote, hr, table');
//
//    // shouldPreviewScroll(length)
//    var body = document.getElementById("preview");
//    var elems = body.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li, pre, blockquote, hr, table');
//    if (elems.length > 0) {
//        previewWrapper.scrollTop = elems[totalLines.length].offsetTop;
//    }
//});


function selectionChanger(selection,operator,endoperator){
    if(selection == ""){
        return operator;
    }
    if(!endoperator){
        endoperator = operator
    }
    var isApplied = selection.slice(0, 2) === operator && selection.slice(-2) === endoperator;
    var finaltext = isApplied ? selection.slice(2, -2) : operator + selection + endoperator;
    return finaltext;
}

editor.addKeyMap({
    // bold
    'Ctrl-B': function(cm) {
        cm.replaceSelection(selectionChanger(cm.getSelection(),'**'));
    },
    // italic
    'Ctrl-I': function(cm) {
        cm.replaceSelection(selectionChanger(cm.getSelection(),'_'));
    },
    // code
    'Ctrl-K': function(cm) {
        cm.replaceSelection(selectionChanger(cm.getSelection(),'`'));
    },
    // keyboard shortcut
    'Ctrl-L': function(cm) {
        cm.replaceSelection(selectionChanger(cm.getSelection(),'<kbd>','</kbd>'));
    }
});

document.addEventListener('drop', function(e) {
    e.preventDefault();
    e.stopPropagation();

    var reader = new FileReader();
    reader.onload = function(e) {
        editor.setValue(e.target.result);
    };

    reader.readAsText(e.dataTransfer.files[0]);
}, false);

//Print the document named as the document title encoded to avoid strange chars and spaces
function saveAsMarkdown() {
    save(editor.getValue(), document.title.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/\s]/gi, '') + ".md");
}

//Print the document named as the document title encoded to avoid strange chars and spaces
function saveAsHtml() {
    save(document.getElementById('out').innerHTML, document.title.replace(/[`~!@#$%^&*()_|+\-=?;:'",.<>\{\}\[\]\\\/\s]/gi, '') + ".html");
}

document.getElementById('saveas-markdown').addEventListener('click', function() {
    saveAsMarkdown();
    hideMenu();
});

document.getElementById('saveas-html').addEventListener('click', function() {
    saveAsHtml();
    hideMenu();
});

function save(code, name) {
    var blob = new Blob([code], {
        type: 'text/plain'
    });
    if (window.saveAs) {
        window.saveAs(blob, name);
    } else if (navigator.saveBlob) {
        navigator.saveBlob(blob, name);
    } else {
        url = URL.createObjectURL(blob);
        var link = document.createElement("a");
        link.setAttribute("href", url);
        link.setAttribute("download", name);
        var event = document.createEvent('MouseEvents');
        event.initMouseEvent('click', true, true, window, 1, 0, 0, 0, 0, false, false, false, false, 0, null);
        link.dispatchEvent(event);
    }
}

var menuVisible = false;
var menu = document.getElementById('menu');

function showMenu() {
    menuVisible = true;
    menu.style.display = 'block';
}

function hideMenu() {
    menuVisible = false;
    menu.style.display = 'none';
}

function openFile(evt) {
    if (window.File && window.FileReader && window.FileList && window.Blob) {
        var files = evt.target.files;
        console.log(files);
        var reader = new FileReader();
        reader.onload = function(file) {
            console.log(file.target.result);
            editor.setValue(file.target.result);
            return true;
        };
        reader.readAsText(files[0]);

    } else {
        alert('The File APIs are not fully supported in this browser.');
    }
}

document.getElementById('close-menu').addEventListener('click', function() {
    hideMenu();
});

document.addEventListener('keydown', function(e) {
    if (e.keyCode == 83 && (e.ctrlKey || e.metaKey)) {
        if ( localStorage.getItem('content') == editor.getValue() ) {
            e.preventDefault();
            return false;
        }
        // e.shiftKey ? showMenu() : saveInBrowser();
        saveX();
        e.preventDefault();
        return false;
    }

    if (e.keyCode === 27 && menuVisible) {
        hideMenu();

        e.preventDefault();
        return false;
    }
});

function clearEditor() {
    editor.setValue("");
}

function saveX() {
    var t = editor.getValue();
    t = btoa(RawDeflate.deflate(unescape(encodeURIComponent(t))))
    t = "[InternetShortcut]\nURL=file:///Users/zedozedo/W/new_git/markdown-editor/index.html#" + t
    save(t, filename);
}

function saveInBrowser() {
    var text = editor.getValue();
    if (localStorage.getItem('content')) {
        swal({
                title: "Existing Data Detected",
                text: "You will overwrite the data previously saved!",
                type: "warning",
                showCancelButton: true,
                confirmButtonColor: "#DD6B55",
                confirmButtonText: "Yes, overwrite!",
                closeOnConfirm: false
            },
            function() {
                localStorage.setItem('content', text);
                swal("Saved", "Your Document has been saved.", "success");
            });
    } else {
        localStorage.setItem('content', text);
        swal("Saved", "Your Document has been saved.", "success");
    }
    console.log("Saved");
}

function toggleNightMode(button) {
    button.classList.toggle('selected');
    document.getElementById('toplevel').classList.toggle('nightmode');
}

function toggleReadMode(button) {
    button.classList.toggle('selected');
    document.getElementById('out').classList.toggle('focused');
    document.getElementById('in').classList.toggle('hidden');
}

function toggleSpellCheck(button) {
    button.classList.toggle('selected');
    document.body.classList.toggle('no-spellcheck');
}

function updateHash() {
    window.location.hash = btoa( // base64 so url-safe
        RawDeflate.deflate( // gzip
            unescape(encodeURIComponent( // convert to utf8
                editor.getValue()
            ))
        )
    );
}

function processQueryParams() {
    var params = window.location.search.split('?')[1];
    if (window.location.hash) {
        //document.getElementById('readbutton').click(); // Show reading view
    }
    if (params) {
        var obj = {};
        params.split('&').forEach(function(elem) {
            obj[elem.split('=')[0]] = elem.split('=')[1];
        });
        if (obj.reading === 'false') {
            document.getElementById('readbutton').click(); // Hide reading view
        }
        if (obj.dark === 'true') {
            document.getElementById('nightbutton').click(); // Show night view
        }
    }
}

//editor.on('change',function() {
//    var t = editor.getScrollInfo();
//    editor.scrollTo(t.left,t.bottom);
//})

function start() {
    processQueryParams();
    if (window.location.hash) {
        var h = window.location.hash.replace(/^#/, '');
        if (h.slice(0, 5) == 'view:') {
            setOutput(decodeURIComponent(escape(RawDeflate.inflate(atob(h.slice(5))))));
            document.body.className = 'view';
        } else {
            editor.setValue(
                decodeURIComponent(escape(
                    RawDeflate.inflate(
                        atob(
                            h
                        )
                    )
                ))
            );
        }
    } else if (localStorage.getItem('content')) {
        editor.setValue(localStorage.getItem('content'));
    }
    update(editor);
    editor.focus();
    document.getElementById('fileInput').addEventListener('change', openFile, false);
//    document.getElementById('toplevel').classList.toggle('nightmode');
    document.body.classList.toggle('no-spellcheck');
}

window.addEventListener("beforeunload", function (e) {
    if (!editor.getValue() || editor.getValue() == localStorage.getItem('content')) {
        return;
    }
    var confirmationMessage = 'It looks like you have been editing something. '
                            + 'If you leave before saving, your changes will be lost.';
    (e || window.event).returnValue = confirmationMessage; //Gecko + IE
    return confirmationMessage; //Gecko + Webkit, Safari, Chrome etc.
});

var date = new Date();
const formatDate = (date)=>{
        let formatted_date =
        date.getFullYear() +
        "_" + (date.getMonth() + 1) +
        "_" + date.getDate() +
        "_" + date.getHours() +
        "_" + date.getMinutes() +
        "_" + date.getSeconds()
        return formatted_date;
    }
filename=formatDate(date) + ".url";
start();
