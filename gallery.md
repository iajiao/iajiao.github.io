---
layout: page
title: "Pic"
description: "「喜欢的，热爱的，欣赏的……」"
permalink: /gallery/
---

<style>
.waterfall {
  column-count: 3;
  column-gap: 20px;
  margin-top: 20px;
}
.waterfall-item {
  break-inside: avoid;
  margin-bottom: 20px;
  cursor: pointer;
}
.waterfall-item img {
  width: 100%;
  border-radius: 8px;
  display: block;
}
.lightbox {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.9);
  z-index: 9999;
  justify-content: center;
  align-items: center;
}
.lightbox.active {
  display: flex;
}
.lightbox img {
  max-width: 90%;
  max-height: 90%;
  border-radius: 4px;
}
.lightbox-close {
  position: absolute;
  top: 20px;
  right: 30px;
  font-size: 40px;
  color: white;
  cursor: pointer;
  background: none;
  border: none;
}
@media (max-width: 768px) {
  .waterfall { column-count: 2; }
}
@media (max-width: 480px) {
  .waterfall { column-count: 1; }
}
</style>

<div class="waterfall">
  {% if site.data.gallery.size > 0 %}
    {% for photo in site.data.gallery %}
    <div class="waterfall-item" onclick="openLightbox('{{ photo.image }}')">
      <img src="{{ photo.image }}" alt="{{ photo.title }}" loading="lazy">
    </div>
    {% endfor %}
  {% else %}
    <p style="text-align:center;">📷 暂无照片</p>
  {% endif %}
</div>

<div id="lightbox" class="lightbox" onclick="closeLightbox()">
  <button class="lightbox-close" onclick="closeLightbox()">&times;</button>
  <img id="lightboxImg" src="" alt="">
</div>

<script>
function openLightbox(url) {
  document.getElementById('lightboxImg').src = url;
  document.getElementById('lightbox').classList.add('active');
  document.body.style.overflow = 'hidden';
}
function closeLightbox() {
  document.getElementById('lightbox').classList.remove('active');
  document.body.style.overflow = '';
}
document.addEventListener('keydown', e => {
  if (e.key === 'Escape') closeLightbox();
});
</script>
