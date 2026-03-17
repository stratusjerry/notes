A collection of tech terms
===

- `Semaphore` : a variable or abstract data type used to control access to a common resource by multiple threads
- `anti-pattern` : a common solution to a problem that is ineffective and can lead to negative consequences
- `footgun` : prominent feature that's easy to misuse, often with harmful consequences

## AI related
- `prompt processing` (pp) : "prefill" happens before LLM generates response tokens
- `time to first token` (ttft) : delay between processed prompt and fist LLM generated completion (response) token
- `K/V Cache` (Key/Value) : used to store response token sequence
- `Speculative decoding` : use a small model to generate initial completion tokens which are then verified by a larger model. Speeds up processing 2-3x by not relying on large model for all completion tokens
- `optimizers` : algorithms that adjust neural network parameters (weights and biases) to minimize a loss function during training
- `transformers` : underlying architecture for almost every modern AI system that understands context by looking at all parts of data at once—allowing it to generate smarter, more accurate insights and predictions at scale https://huggingface.co/spaces/yonigozlan/Transformers-Timeline
