document.addEventListener("DOMContentLoaded", function () {
  var header = document.querySelector(".site-header");
  var toggle = document.querySelector(".nav-toggle");
  var nav = document.querySelector(".nav-main");

  function updateHeader() {
    if (window.scrollY > 24) {
      header.classList.add("solid");
    } else if (!nav.classList.contains("open")) {
      header.classList.remove("solid");
    }
  }

  if (header) {
    window.addEventListener("scroll", updateHeader, { passive: true });
    updateHeader();
  }

  if (toggle && nav) {
    toggle.addEventListener("click", function () {
      var isOpen = nav.classList.toggle("open");
      toggle.setAttribute("aria-expanded", isOpen ? "true" : "false");
      header.classList.toggle("solid", isOpen || window.scrollY > 24);
    });

    nav.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", function () {
        nav.classList.remove("open");
        toggle.setAttribute("aria-expanded", "false");
        updateHeader();
      });
    });
  }

  var yearEl = document.querySelector("[data-year]");
  if (yearEl) {
    yearEl.textContent = new Date().getFullYear();
  }

  var form = document.querySelector(".contact-form form");
  if (form) {
    var lang = (document.documentElement.lang || "pt-BR").slice(0, 2).toLowerCase();
    var i18n = {
      pt: {
        subject: "Solicitação de contato - Site JF Aviation",
        name: "Nome", phone: "Telefone", email: "E-mail", topic: "Assunto",
        status: "Abrindo seu aplicativo de e-mail para concluir o envio..."
      },
      en: {
        subject: "Contact request - JF Aviation Website",
        name: "Name", phone: "Phone", email: "Email", topic: "Subject",
        status: "Opening your email app to complete the submission..."
      },
      es: {
        subject: "Solicitud de contacto - Sitio JF Aviation",
        name: "Nombre", phone: "Teléfono", email: "Correo electrónico", topic: "Asunto",
        status: "Abriendo tu aplicación de correo para completar el envío..."
      }
    };
    var t = i18n[lang] || i18n.pt;

    form.addEventListener("submit", function (e) {
      e.preventDefault();
      var status = form.querySelector(".form-status");
      var name = form.querySelector("#nome").value.trim();
      var bodyLines = [
        t.name + ": " + name,
        t.phone + ": " + form.querySelector("#telefone").value.trim(),
        t.email + ": " + form.querySelector("#email").value.trim(),
        t.topic + ": " + form.querySelector("#assunto").value,
        "",
        form.querySelector("#mensagem").value.trim()
      ];
      var mailto = "mailto:sec.pres@jfaviation.com.br" +
        "?subject=" + encodeURIComponent(t.subject) +
        "&body=" + encodeURIComponent(bodyLines.join("\n"));
      window.location.href = mailto;
      if (status) {
        status.textContent = t.status;
        status.style.display = "block";
      }
    });
  }
});
