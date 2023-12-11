## Help

<a id='help-intro'></a>
### 1. Quick theoretical introduction

By a sequence $s_i=<s_{i1}, s_{i2},...,s_{in}>$ we understand an ordered multiset of elements, where each element $s_{ik}$, $k=1..|s_i|$ is drawn from some set $\mathcal{E}$. Given two sequences $s_1$, $s_2$, the edit distance $\delta(s_1, s_2)$ between them is defined using the following recursive formula:

$$\delta(s_1, s_2) = \min
\begin{cases}
    \delta\left(s_1,s_2-s_{2\rightarrow}\right) + c_{ins}\left(s_{2\rightarrow}\right) \\
    \delta\left(s_1-s_{1\rightarrow},s_2\right) + c_{del}\left(s_{1\rightarrow}\right) \\
    \delta\left(s_1-s_{1\rightarrow},s_2-s_{2\rightarrow}\right) + c_{rel}\left(s_{1\rightarrow}, s_{2\rightarrow}\right) \\
\end{cases}$$

with stop conditions defined as:
$\delta(\emptyset, \emptyset) = 0$
$\delta(s_1, \emptyset) = \delta(s_1-s_{1\rightarrow}, \emptyset) + c_{del}\left(s_{1\rightarrow}\right)$
$\delta(\emptyset, s_2) = \delta(\emptyset, s_2-s_{2\rightarrow}, ) + c_{ins}\left(s_{2\rightarrow}\right)$
where $s_{i\rightarrow}$ is the rightmost element of sequence $s_i, s_i-s_{i\rightarrow}$ is $s_i$ without its rightmost element, and $c_{del/ins/rel}$ are cost functions for deletion, insertion, and relabeling, respectively.

<a id='help-conf'></a>
### 3. Creating  a dataset

You can configure the dataset by using the inputs available in the left sidebar (upper panel on small screens). The basic configuration options involve:

- **X**: asdf
- **Y**: asdf
- **Z**: asdf


<a id='help-animation'></a>
### 3. Animations

Some of the application options can be animated. These options can change the visualization parameters automatically in constant intervals creating an animation. To trigger such an animation look for the <i class="glyphicon glyphicon-play" style="color: #337ab7"></i> button  underneath sliders. Animated options include: *Correlation probability* and *Recency weight*.

<a id='help-contact'></a>
### 9. Contact

<a href="#" onclick="$('body,html').animate({scrollTop : 0}, 500);" class="return-to-top" title="Scroll to top"><i class="fa fa-chevron-up"></i></a>

